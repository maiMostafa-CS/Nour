package com.example.islamic_app

import android.app.Application
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class MyApplication : Application() {

    companion object {
        const val KHATMA_CHANNEL = "com.example.islamic_app/khatma"
        const val UNLOCK_CARD_CHANNEL = "prayer_app/unlock_card"

        // ✅ messenger دائم
        var flutterMessenger: BinaryMessenger? = null
            private set

        // ✅ engine شغال طول الوقت
        private var backgroundEngine: FlutterEngine? = null
    }

    override fun onCreate() {
        super.onCreate()

        Log.d("KhatmaNative", "🚀 MyApplication.onCreate")

        // ============================================================
        // أنشئ engine مستقل
        // ============================================================

        val engineGroup = FlutterEngineGroup(this)

        backgroundEngine = engineGroup.createAndRunEngine(
            this,
            DartExecutor.DartEntrypoint.createDefault()
        )

        // ✅ خزّن الـ messenger
        flutterMessenger = backgroundEngine!!.dartExecutor.binaryMessenger

        Log.d("KhatmaNative", "✅ Background engine started")
    }
}