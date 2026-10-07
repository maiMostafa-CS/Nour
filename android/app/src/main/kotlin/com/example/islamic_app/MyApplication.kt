package com.example.islamic_app

import android.app.Application
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class MyApplication : Application() {

    companion object {
        const val TAG = "MyApplication"

        const val KHATMA_CHANNEL = "com.example.islamic_app/khatma"
        const val ADHAN_CHANNEL = "com.example.islamic_app/adhan"
        const val UNLOCK_CARD_CHANNEL = "prayer_app/unlock_card"   // ← ✅ تمت الإضافة
        const val KHATMA_PREFS = "khatma_unlock"
        const val KHATMA_WEEKLY_PREFS = "khatma_weekly"
        const val PRAYER_CARD_PREFS = "prayer_card"

        var flutterMessenger: BinaryMessenger? = null
            private set

        var instance: MyApplication? = null
            private set

        private var backgroundEngine: FlutterEngine? = null

        // ============================================================
        // ✅ Notify Flutter: Khatma Read
        // ============================================================

        fun notifyKhatmaRead() {
            Log.d(TAG, "📖 notifyKhatmaRead called")

            val messenger = flutterMessenger
            if (messenger == null) {
                Log.e(TAG, "❌ Flutter messenger is null")
                return
            }

            try {
                MethodChannel(messenger, KHATMA_CHANNEL)
                    .invokeMethod("notifyKhatmaRead", null)

                Log.d(TAG, "🚀 notifyKhatmaRead sent to Flutter")
            } catch (e: Exception) {
                Log.e(TAG, "❌ Failed to send notifyKhatmaRead", e)
            }
        }

        // ============================================================
        // ✅ Notify Flutter: Stop Adhan
        // ============================================================

        fun stopAdhan() {
            Log.d(TAG, "🛑 stopAdhan called")
            try {
                val alarmService = com.gdelataillade.alarm.alarm.AlarmService.instance
                if (alarmService != null) {
                    val ringingIds = com.gdelataillade.alarm.alarm.AlarmService.ringingAlarmIds.toList()
                    for (id in ringingIds) {
                        Log.d(TAG, "🛑 Native stopping ringing alarm id=$id")
                        alarmService.handleStopAlarmCommand(id)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "⚠️ Error in native AlarmService stop: $e")
            }

            val messenger = flutterMessenger
            if (messenger != null) {
                try {
                    MethodChannel(messenger, ADHAN_CHANNEL)
                        .invokeMethod("stopAdhan", null)
                    Log.d(TAG, "🚀 stopAdhan forwarded to Flutter")
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Failed to send stopAdhan to Flutter", e)
                }
            }
        }
    }

    // ================================================================
    // Lifecycle
    // ================================================================

    override fun onCreate() {
        super.onCreate()

        instance = this

        Log.d(TAG, "🚀 MyApplication.onCreate")

        // ============================================================
        // 1. Create background engine
        // ============================================================

        backgroundEngine = FlutterEngine(this).apply {
            dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(
                    FlutterInjector.instance()
                        .flutterLoader()
                        .findAppBundlePath(),
                    "backgroundMain"
                )
            )
        }

        flutterMessenger = backgroundEngine!!.dartExecutor.binaryMessenger

        // ============================================================
        // 2. Register Khatma channel in background engine
        // ============================================================

        registerKhatmaChannel(backgroundEngine!!)

        // ============================================================
        // 3. Start call state listener
        // ============================================================

        CallStateListener.start(this)

        Log.d(TAG, "✅ Background engine started")
    }

    // ================================================================
    // Khatma Channel Registration
    // ================================================================

    private fun registerKhatmaChannel(engine: FlutterEngine) {
        MethodChannel(
            engine.dartExecutor.binaryMessenger,
            KHATMA_CHANNEL
        ).setMethodCallHandler { call, result ->

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

                    getSharedPreferences(KHATMA_PREFS, MODE_PRIVATE)
                        .edit()
                        .putInt("globalNumber", globalNumber)
                        .putInt("surahNumber", surahNumber)
                        .putInt("ayahNumber", ayahNumber)
                        .putString("surahName", surahName)
                        .putString("text", text)
                        .putInt("pageNumber", pageNumber)
                        .apply()

                    Log.d(TAG, "✅ [BG] Current ayah saved: $surahName $ayahNumber")
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

                    getSharedPreferences(KHATMA_WEEKLY_PREFS, MODE_PRIVATE)
                        .edit()
                        .putInt("totalAyahs", totalAyahs)
                        .putInt("currentWeekAyahs", currentWeekAyahs)
                        .putInt("weekNumber", weekNumber)
                        .apply()

                    Log.d(
                        TAG,
                        "📊 [BG] Weekly report saved: total=$totalAyahs, week=$weekNumber"
                    )

                    result.success(true)
                }

                "hasPendingRead" -> {
                    val hasPending = getSharedPreferences(KHATMA_PREFS, MODE_PRIVATE)
                        .getBoolean("pending_read", false)
                    Log.d(TAG, "🔍 [BG] hasPendingRead = $hasPending")
                    result.success(hasPending)
                }

                "clearPendingRead" -> {
                    getSharedPreferences(KHATMA_PREFS, MODE_PRIVATE)
                        .edit()
                        .putBoolean("pending_read", false)
                        .apply()
                    Log.d(TAG, "🧹 [BG] pending_read cleared")
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }
}