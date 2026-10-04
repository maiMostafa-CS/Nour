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
                        isCallActive = true
                        Log.d(TAG, "📞 Call ringing → stopping adhan")
                        stopAdhan()
                    }
                    TelephonyManager.CALL_STATE_OFFHOOK -> {
                        isCallActive = true
                        Log.d(TAG, "📞 Call active → stopping adhan")
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
        val messenger = MyApplication.flutterMessenger

        if (messenger == null) {
            Log.e(TAG, "❌ Flutter messenger is null - saving flag instead")

            // ✅ احفظ flag في FlutterSharedPreferences
            appContext?.getSharedPreferences(
                PREFS_NAME,
                Context.MODE_PRIVATE
            )
                ?.edit()
                ?.putBoolean(KEY_STOP_ADHAN, true)
                ?.putLong("flutter.stop_adhan_time", System.currentTimeMillis())
                ?.apply()

            return
        }

        try {
            MethodChannel(messenger, ADHAN_CHANNEL)
                .invokeMethod("stopAdhan", null)

            Log.d(TAG, "🚀 stopAdhan sent to background engine")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to send stopAdhan", e)
        }
    }
}