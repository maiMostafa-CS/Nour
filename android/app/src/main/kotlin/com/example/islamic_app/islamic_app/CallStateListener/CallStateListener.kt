package com.example.islamic_app

import android.content.Context
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import android.util.Log
import io.flutter.plugin.common.MethodChannel

object CallStateListener {

    private const val TAG = "CallStateListener"
    private const val ADHAN_CHANNEL = "com.example.islamic_app/adhan"

    // ✅ نفس اسم FlutterSharedPreferences عشان Flutter تقراها
    private const val PREFS_NAME = "FlutterSharedPreferences"
    private const val KEY_STOP_ADHAN = "flutter.stop_adhan_requested"

    private var telephonyManager: TelephonyManager? = null
    private var listener: PhoneStateListener? = null
    private var appContext: Context? = null   // ✅ جديد

    var isCallActive: Boolean = false
        private set

    fun start(context: Context) {
        if (listener != null) {
            Log.d(TAG, "Already listening")
            return
        }

        appContext = context.applicationContext   // ✅ خزّن

        telephonyManager = context.getSystemService(
            Context.TELEPHONY_SERVICE
        ) as? TelephonyManager

        listener = object : PhoneStateListener() {
            override fun onCallStateChanged(
                state: Int,
                phoneNumber: String?
            ) {
                when (state) {
                    TelephonyManager.CALL_STATE_IDLE -> {
                        isCallActive = false
                        Log.d(TAG, "📞 Call ended (IDLE)")
                    }
                    TelephonyManager.CALL_STATE_RINGING -> {
                        // لا نوقف الأذان عند الرنين فقط —
                        // ننتظر حتى يتم الرد على الاتصال فعلياً (OFFHOOK).
                        isCallActive = true
                        Log.d(TAG, "📞 Incoming call ringing — waiting for answer before stopping adhan")
                    }
                    TelephonyManager.CALL_STATE_OFFHOOK -> {
                        // اتصال نشط (تم الرد) → نوقف الأذان فقط.
                        // الإقامة لا تتأثر، Flutter يتولى ذلك بتوقيف 'adhan' payload فقط.
                        isCallActive = true
                        Log.d(TAG, "📞 Call active (OFFHOOK) → stopping adhan only")
                        stopAdhan()
                    }
                }
            }
        }

        telephonyManager?.listen(
            listener,
            PhoneStateListener.LISTEN_CALL_STATE
        )

        Log.d(TAG, "✅ CallStateListener started")
    }

    fun stop() {
        listener?.let {
            telephonyManager?.listen(it, PhoneStateListener.LISTEN_NONE)
        }
        listener = null
        telephonyManager = null
        Log.d(TAG, "🛑 CallStateListener stopped")
    }

    private fun stopAdhan() {
        try {
            // 1. Direct native stop: stop ONLY the alarm currently playing audio
            val alarmService = com.gdelataillade.alarm.alarm.AlarmService.instance
            if (alarmService != null) {
                val ringingIds = com.gdelataillade.alarm.alarm.AlarmService.ringingAlarmIds.toList()
                for (id in ringingIds) {
                    Log.d(TAG, "🛑 Native stopping currently ringing alarm id=$id")
                    alarmService.handleStopAlarmCommand(id)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "⚠️ Direct native AlarmService stop exception: $e")
        }

        // 2. Also notify Flutter if an engine is connected (safely)
        val messenger = MyApplication.flutterMessenger
        if (messenger != null) {
            try {
                MethodChannel(messenger, ADHAN_CHANNEL)
                    .invokeMethod("stopAdhan", null)
                Log.d(TAG, "🚀 stopAdhan forwarded to Flutter")
            } catch (e: Exception) {
                Log.e(TAG, "❌ Failed to forward stopAdhan to Flutter", e)
            }
        }
    }
}