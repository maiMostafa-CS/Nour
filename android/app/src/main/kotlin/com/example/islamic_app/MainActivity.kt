package com.example.islamic_app

import android.content.Context
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // ============================================================
    // Flutter Engine Configuration
    // ============================================================

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ✅ قناة stopAdhan (تستجيب لـ Dart)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MyApplication.ADHAN_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "stopAdhan" -> {
                    Log.d(MyApplication.TAG, "🛑 stopAdhan received from Flutter")
                    stopAdhan()
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
            Log.e(MyApplication.TAG, "❌ Flutter messenger is null - saving flag instead")

            // ✅ خزّن إشارة في Native SharedPreferences
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

            Log.d(MyApplication.TAG, "🚀 stopAdhan sent to Flutter")
        } catch (e: Exception) {
            Log.e(MyApplication.TAG, "❌ Failed to send stopAdhan", e)
        }
    }
}