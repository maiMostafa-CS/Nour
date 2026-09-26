package com.example.islamic_app

import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {

        // ============================================================
        // Channels
        // ============================================================

        private const val KHATMA_CHANNEL =
            "com.example.islamic_app/khatma"

        private const val UNLOCK_CARD_CHANNEL =
            "prayer_app/unlock_card"

        // ============================================================
        // SharedPreferences
        // ============================================================

        private const val KHATMA_PREFS =
            "khatma_unlock"

        private const val KHATMA_WEEKLY_PREFS =
            "khatma_weekly"

        private const val PRAYER_CARD_PREFS =
            "prayer_card"

        // ============================================================
        // Flutter Messenger
        // ============================================================

        private var flutterMessenger: BinaryMessenger? = null

        // ============================================================
        // Send Khatma Read Event to Flutter
        // ============================================================

        fun notifyKhatmaRead() {

            flutterMessenger?.let { messenger ->

                Log.d(
                    "KhatmaNative",
                    "🚀 Sending markCurrentAyahAsRead directly to Flutter"
                )

                MethodChannel(
                    messenger,
                    KHATMA_CHANNEL
                ).invokeMethod(
                    "markCurrentAyahAsRead",
                    null
                )

            } ?: run {

                Log.e(
                    "KhatmaNative",
                    "❌ Flutter messenger is null - " +
                            "pending_read flag will be processed on next app open"
                )
            }
        }
    }

    // ================================================================
    // Flutter Engine
    // ================================================================

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        // ============================================================
        // Save Flutter Messenger
        // ============================================================

        flutterMessenger =
            flutterEngine.dartExecutor.binaryMessenger

        Log.d(
            "KhatmaNative",
            "✅ Flutter messenger initialized"
        )

        // ============================================================
        // Khatma Channel
        // ============================================================

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            KHATMA_CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                // ====================================================
                // Save Current Ayah
                // ====================================================

                "saveCurrentAyah" -> {

                    val args =
                        call.arguments as? Map<*, *>

                    if (args == null) {

                        result.error(
                            "INVALID_ARGUMENTS",
                            "Khatma ayah arguments are missing",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    val globalNumber =
                        (args["globalNumber"] as? Number)
                            ?.toInt()

                    val surahNumber =
                        (args["surahNumber"] as? Number)
                            ?.toInt()

                    val ayahNumber =
                        (args["ayahNumber"] as? Number)
                            ?.toInt()

                    val surahName =
                        args["surahName"] as? String

                    val text =
                        args["text"] as? String

                    val pageNumber =
                        (args["pageNumber"] as? Number)
                            ?.toInt()

                    // =================================================
                    // Validate
                    // =================================================

                    if (
                        globalNumber == null ||
                        surahNumber == null ||
                        ayahNumber == null ||
                        surahName.isNullOrBlank() ||
                        text.isNullOrBlank() ||
                        pageNumber == null
                    ) {

                        result.error(
                            "INVALID_AYAH",
                            "Incomplete Khatma ayah data",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    // =================================================
                    // Save
                    // =================================================

                    getSharedPreferences(
                        KHATMA_PREFS,
                        MODE_PRIVATE
                    )
                        .edit()
                        .putInt(
                            "globalNumber",
                            globalNumber
                        )
                        .putInt(
                            "surahNumber",
                            surahNumber
                        )
                        .putInt(
                            "ayahNumber",
                            ayahNumber
                        )
                        .putString(
                            "surahName",
                            surahName
                        )
                        .putString(
                            "text",
                            text
                        )
                        .putInt(
                            "pageNumber",
                            pageNumber
                        )
                        .apply()

                    Log.d(
                        "KhatmaNative",
                        "✅ Current ayah saved: $surahName $ayahNumber"
                    )

                    result.success(true)
                }

                // ====================================================
                // Save Weekly Khatma Report
                // ====================================================

                "saveWeeklyReport" -> {

                    val args =
                        call.arguments as? Map<*, *>

                    if (args == null) {

                        result.error(
                            "INVALID_ARGUMENTS",
                            "Weekly report arguments are missing",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    val totalAyahs =
                        (args["totalAyahs"] as? Number)
                            ?.toInt()

                    val currentWeekAyahs =
                        (args["currentWeekAyahs"] as? Number)
                            ?.toInt()

                    val weekNumber =
                        (args["weekNumber"] as? Number)
                            ?.toInt()

                    // =================================================
                    // Validate
                    // =================================================

                    if (
                        totalAyahs == null ||
                        currentWeekAyahs == null ||
                        weekNumber == null
                    ) {

                        result.error(
                            "INVALID_WEEKLY_REPORT",
                            "Incomplete weekly report data",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    // =================================================
                    // Save Weekly Report
                    // =================================================

                    getSharedPreferences(
                        KHATMA_WEEKLY_PREFS,
                        MODE_PRIVATE
                    )
                        .edit()
                        .putInt(
                            "totalAyahs",
                            totalAyahs
                        )
                        .putInt(
                            "currentWeekAyahs",
                            currentWeekAyahs
                        )
                        .putInt(
                            "weekNumber",
                            weekNumber
                        )
                        .apply()

                    Log.d(
                        "KhatmaNative",
                        "📊 Weekly report saved: " +
                                "total=$totalAyahs, " +
                                "currentWeek=$currentWeekAyahs, " +
                                "week=$weekNumber"
                    )

                    result.success(true)
                }

                // ====================================================
                // Has Pending Read
                // ====================================================

                "hasPendingRead" -> {

                    val hasPending =
                        getSharedPreferences(
                            KHATMA_PREFS,
                            MODE_PRIVATE
                        )
                            .getBoolean(
                                "pending_read",
                                false
                            )

                    Log.d(
                        "KhatmaNative",
                        "🔍 hasPendingRead = $hasPending"
                    )

                    result.success(hasPending)
                }

                // ====================================================
                // Clear Pending Read
                // ====================================================

                "clearPendingRead" -> {

                    getSharedPreferences(
                        KHATMA_PREFS,
                        MODE_PRIVATE
                    )
                        .edit()
                        .putBoolean(
                            "pending_read",
                            false
                        )
                        .apply()

                    Log.d(
                        "KhatmaNative",
                        "🧹 pending_read cleared"
                    )

                    result.success(true)
                }

                // ====================================================
                // Unknown Khatma Method
                // ====================================================

                else -> {
                    result.notImplemented()
                }
            }
        }

        // ============================================================
        // Unlock Card Channel
        // ============================================================

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            UNLOCK_CARD_CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                // ====================================================
                // Is Enabled
                // ====================================================

                "isEnabled" -> {

                    val enabled =
                        getSharedPreferences(
                            PRAYER_CARD_PREFS,
                            MODE_PRIVATE
                        )
                            .getBoolean(
                                "enabled",
                                false
                            )

                    Log.d(
                        "UnlockCard",
                        "ℹ️ Service enabled = $enabled"
                    )

                    result.success(enabled)
                }

                // ====================================================
                // Start Service
                // ====================================================

                "startService" -> {

                    val prefs =
                        getSharedPreferences(
                            PRAYER_CARD_PREFS,
                            MODE_PRIVATE
                        )

                    // ------------------------------------------------
                    // Save enabled state FIRST
                    // ------------------------------------------------

                    prefs.edit()
                        .putBoolean(
                            "enabled",
                            true
                        )
                        .apply()

                    // ------------------------------------------------
                    // Check Overlay Permission
                    // ------------------------------------------------

                    if (!Settings.canDrawOverlays(this)) {

                        Log.e(
                            "UnlockCard",
                            "❌ Overlay permission is not granted"
                        )

                        result.success(false)

                        return@setMethodCallHandler
                    }

                    // ------------------------------------------------
                    // Start Foreground Service
                    // ------------------------------------------------

                    val serviceIntent =
                        Intent(
                            this,
                            UnlockService::class.java
                        )

                    try {

                        if (
                            Build.VERSION.SDK_INT >=
                            Build.VERSION_CODES.O
                        ) {

                            startForegroundService(
                                serviceIntent
                            )

                        } else {

                            startService(
                                serviceIntent
                            )
                        }

                        Log.d(
                            "UnlockCard",
                            "✅ UnlockService started"
                        )

                        result.success(true)

                    } catch (e: Exception) {

                        prefs.edit()
                            .putBoolean(
                                "enabled",
                                false
                            )
                            .apply()

                        Log.e(
                            "UnlockCard",
                            "❌ Failed to start UnlockService",
                            e
                        )

                        result.error(
                            "SERVICE_START_FAILED",
                            "Failed to start UnlockService",
                            e.message
                        )
                    }
                }

                // ====================================================
                // Stop Service
                // ====================================================

                "stopService" -> {

                    val prefs =
                        getSharedPreferences(
                            PRAYER_CARD_PREFS,
                            MODE_PRIVATE
                        )

                    // ------------------------------------------------
                    // Save disabled state
                    // ------------------------------------------------

                    prefs.edit()
                        .putBoolean(
                            "enabled",
                            false
                        )
                        .apply()

                    // ------------------------------------------------
                    // Stop Service
                    // ------------------------------------------------

                    try {

                        stopService(
                            Intent(
                                this,
                                UnlockService::class.java
                            )
                        )

                        Log.d(
                            "UnlockCard",
                            "🛑 UnlockService stopped"
                        )

                        result.success(true)

                    } catch (e: Exception) {

                        Log.e(
                            "UnlockCard",
                            "❌ Failed to stop UnlockService",
                            e
                        )

                        result.error(
                            "SERVICE_STOP_FAILED",
                            "Failed to stop UnlockService",
                            e.message
                        )
                    }
                }

                // ====================================================
                // Overlay Permission
                // ====================================================

                "hasOverlayPermission" -> {

                    val hasPermission =
                        Settings.canDrawOverlays(
                            this
                        )

                    result.success(
                        hasPermission
                    )
                }

                // ====================================================
                // Request Overlay Permission
                // ====================================================

                "requestOverlayPermission" -> {

                    val permissionIntent =
                        Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            android.net.Uri.parse(
                                "package:$packageName"
                            )
                        )

                    startActivity(
                        permissionIntent
                    )

                    result.success(true)
                }

                // ====================================================
                // Test Card
                // ====================================================

                "showTestCard" -> {

                    PrayerCardOverlay.show(
                        this,
                        "اختبار آية",
                        "سورة الفاتحة • آية 1"
                    )

                    result.success(true)
                }

                // ====================================================
                // Unknown Unlock Card Method
                // ====================================================

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // ================================================================
    // Activity Destroyed
    // ================================================================

    override fun onDestroy() {

        flutterMessenger = null

        Log.d(
            "KhatmaNative",
            "🛑 Flutter messenger cleared"
        )

        super.onDestroy()
    }
}