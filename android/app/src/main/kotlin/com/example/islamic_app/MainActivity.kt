package com.example.islamic_app

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // ============================================================
        // 1. قناة ADHAN
        // ============================================================

        MethodChannel(messenger, MyApplication.ADHAN_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "stopAdhan" -> {
                        Log.d(MyApplication.TAG, "🛑 stopAdhan received")
                        stopAdhan()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        // ============================================================
        // 2. قناة KHATMA
        // ============================================================

        MethodChannel(messenger, MyApplication.KHATMA_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "saveCurrentAyah" -> {
                        val args = call.arguments as? Map<*, *>
                        if (args == null) {
                            result.error("INVALID_ARGUMENTS", "missing", null)
                            return@setMethodCallHandler
                        }

                        val globalNumber = (args["globalNumber"] as? Number)?.toInt()
                        val surahNumber = (args["surahNumber"] as? Number)?.toInt()
                        val ayahNumber = (args["ayahNumber"] as? Number)?.toInt()
                        val surahName = args["surahName"] as? String
                        val text = args["text"] as? String
                        val pageNumber = (args["pageNumber"] as? Number)?.toInt()

                        if (
                            globalNumber == null || surahNumber == null ||
                            ayahNumber == null || surahName.isNullOrBlank() ||
                            text.isNullOrBlank() || pageNumber == null
                        ) {
                            result.error("INVALID_AYAH", "incomplete", null)
                            return@setMethodCallHandler
                        }

                        getSharedPreferences(MyApplication.KHATMA_PREFS, MODE_PRIVATE)
                            .edit()
                            .putInt("globalNumber", globalNumber)
                            .putInt("surahNumber", surahNumber)
                            .putInt("ayahNumber", ayahNumber)
                            .putString("surahName", surahName)
                            .putString("text", text)
                            .putInt("pageNumber", pageNumber)
                            .apply()

                        Log.d(MyApplication.TAG, "✅ [MAIN] Ayah saved: $surahName $ayahNumber")
                        result.success(true)
                    }

                    "saveWeeklyReport" -> {
                        val args = call.arguments as? Map<*, *>
                        if (args == null) {
                            result.error("INVALID_ARGUMENTS", "missing", null)
                            return@setMethodCallHandler
                        }

                        val totalAyahs = (args["totalAyahs"] as? Number)?.toInt()
                        val currentWeekAyahs = (args["currentWeekAyahs"] as? Number)?.toInt()
                        val weekNumber = (args["weekNumber"] as? Number)?.toInt()

                        if (totalAyahs == null || currentWeekAyahs == null || weekNumber == null) {
                            result.error("INVALID_WEEKLY_REPORT", "incomplete", null)
                            return@setMethodCallHandler
                        }

                        getSharedPreferences(MyApplication.KHATMA_WEEKLY_PREFS, MODE_PRIVATE)
                            .edit()
                            .putInt("totalAyahs", totalAyahs)
                            .putInt("currentWeekAyahs", currentWeekAyahs)
                            .putInt("weekNumber", weekNumber)
                            .apply()

                        Log.d(MyApplication.TAG, "📊 [MAIN] Weekly report saved")
                        result.success(true)
                    }

                    "hasPendingRead" -> {
                        val hasPending = getSharedPreferences(
                            MyApplication.KHATMA_PREFS, MODE_PRIVATE
                        ).getBoolean("pending_read", false)
                        Log.d(MyApplication.TAG, "🔍 [MAIN] hasPendingRead = $hasPending")
                        result.success(hasPending)
                    }

                    "clearPendingRead" -> {
                        getSharedPreferences(MyApplication.KHATMA_PREFS, MODE_PRIVATE)
                            .edit()
                            .putBoolean("pending_read", false)
                            .apply()
                        Log.d(MyApplication.TAG, "🧹 [MAIN] pending_read cleared")
                        result.success(true)
                    }

                    "notifyKhatmaRead" -> {
                        Log.d(MyApplication.TAG, "📖 [MAIN] notifyKhatmaRead received")
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }

        // ============================================================
        // 3. قناة UNLOCK_CARD
        // ============================================================

        MethodChannel(messenger, MyApplication.UNLOCK_CARD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "isEnabled" -> {
                        val enabled = getSharedPreferences(
                            MyApplication.PRAYER_CARD_PREFS, MODE_PRIVATE
                        ).getBoolean("enabled", false)
                        Log.d(MyApplication.TAG, "🔍 [MAIN] isEnabled = $enabled")
                        result.success(enabled)
                    }

                    "setEnabled" -> {
                        val args = call.arguments as? Map<*, *>
                        val enabled = args?.get("enabled") as? Boolean ?: false
                        getSharedPreferences(MyApplication.PRAYER_CARD_PREFS, MODE_PRIVATE)
                            .edit()
                            .putBoolean("enabled", enabled)
                            .apply()
                        getSharedPreferences("unlock_card_prefs", MODE_PRIVATE)
                            .edit()
                            .putBoolean("enabled", enabled)
                            .apply()
                        Log.d(MyApplication.TAG, "💾 [MAIN] setEnabled = $enabled")
                        result.success(true)
                    }

                    "startService" -> {
                        val prefs = getSharedPreferences(
                            MyApplication.PRAYER_CARD_PREFS,
                            MODE_PRIVATE
                        )

                        prefs.edit().putBoolean("enabled", true).apply()
                        getSharedPreferences("unlock_card_prefs", MODE_PRIVATE)
                            .edit().putBoolean("enabled", true).apply()

                        if (!Settings.canDrawOverlays(this)) {
                            Log.e(MyApplication.TAG, "❌ Overlay permission is not granted")
                            result.success(false)
                            return@setMethodCallHandler
                        }

                        val serviceIntent = Intent(this, UnlockService::class.java)
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                startForegroundService(serviceIntent)
                            } else {
                                startService(serviceIntent)
                            }
                            Log.d(MyApplication.TAG, "✅ [MAIN] UnlockService started")
                            result.success(true)
                        } catch (e: Exception) {
                            prefs.edit().putBoolean("enabled", false).apply()
                            getSharedPreferences("unlock_card_prefs", MODE_PRIVATE)
                                .edit().putBoolean("enabled", false).apply()
                            Log.e(MyApplication.TAG, "❌ Failed to start UnlockService", e)
                            result.error(
                                "SERVICE_START_FAILED",
                                "Failed to start UnlockService",
                                e.message
                            )
                        }
                    }

                    "stopService" -> {
                        getSharedPreferences(MyApplication.PRAYER_CARD_PREFS, MODE_PRIVATE)
                            .edit().putBoolean("enabled", false).apply()
                        getSharedPreferences("unlock_card_prefs", MODE_PRIVATE)
                            .edit().putBoolean("enabled", false).apply()

                        try {
                            stopService(Intent(this, UnlockService::class.java))
                            Log.d(MyApplication.TAG, "🛑 [MAIN] UnlockService stopped")
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e(MyApplication.TAG, "❌ Failed to stop UnlockService", e)
                            result.error(
                                "SERVICE_STOP_FAILED",
                                "Failed to stop UnlockService",
                                e.message
                            )
                        }
                    }

                    "hasOverlayPermission" -> {
                        val granted = Settings.canDrawOverlays(this)
                        Log.d(MyApplication.TAG, "🔍 [MAIN] hasOverlayPermission = $granted")
                        result.success(granted)
                    }

                    "requestOverlayPermission" -> {
                        try {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            )
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e(MyApplication.TAG, "❌ requestOverlayPermission failed", e)
                            result.success(false)
                        }
                    }

                    "showTestCard" -> {
                        PrayerCardOverlay.show(
                            this,
                            "اختبار آية",
                            "سورة الفاتحة • آية 1"
                        )
                        result.success(true)
                    }

                    "showOverlay" -> {
                        val args = call.arguments as? Map<*, *>
                        val title = args?.get("title") as? String ?: ""
                        val subtitle = args?.get("subtitle") as? String ?: ""
                        PrayerCardOverlay.show(applicationContext, title, subtitle)
                        result.success(true)
                    }

                    "dismissOverlay" -> {
                        PrayerCardOverlay.dismiss(applicationContext)
                        result.success(true)
                    }

                    "savePrayers" -> {
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // ============================================================
    // Stop Adhan
    // ============================================================

    private fun stopAdhan() {
        val messenger = MyApplication.flutterMessenger

        if (messenger == null) {
            Log.e(MyApplication.TAG, "❌ messenger null - saving flag")
            MyApplication.instance?.let { app ->
                app.getSharedPreferences("adhan_control", Context.MODE_PRIVATE)
                    .edit()
                    .putBoolean("stop_adhan_requested", true)
                    .apply()
            }
            return
        }

        try {
            MethodChannel(messenger, MyApplication.ADHAN_CHANNEL)
                .invokeMethod("stopAdhan", null)
            Log.d(MyApplication.TAG, "🚀 stopAdhan sent to background")
        } catch (e: Exception) {
            Log.e(MyApplication.TAG, "❌ Failed to send stopAdhan", e)
        }
    }
}