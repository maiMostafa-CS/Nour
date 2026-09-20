package com.example.islamic_app

import android.content.Context
import android.graphics.PixelFormat
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView

object PrayerCardOverlay {

    private var view: View? = null

    private val handler =
        Handler(Looper.getMainLooper())

// ================================================================
// Show Card
// ================================================================

    fun show(
        context: Context,
        title: String,
        subtitle: String
    ) {
        val app = context.applicationContext

        Log.d(
            "UnlockCard",
            "🔥 PrayerCardOverlay.show()"
        )

        // ============================================================
        // Check Overlay Permission
        // ============================================================

        if (!Settings.canDrawOverlays(app)) {
            Log.e(
                "UnlockCard",
                "❌ Overlay permission NOT granted"
            )
            return
        }

        Log.d(
            "UnlockCard",
            "✅ Overlay permission granted"
        )

        // ============================================================
        // Remove Old Card
        // ============================================================

        dismiss(app)

        // ============================================================
        // Window Manager
        // ============================================================

        val windowManager =
            app.getSystemService(
                Context.WINDOW_SERVICE
            ) as WindowManager

        // ============================================================
        // Inflate Card
        // ============================================================

        val cardView =
            LayoutInflater.from(app).inflate(
                R.layout.overlay_prayer_card,
                null
            )

        // ============================================================
        // Ayah Text
        // ============================================================

        cardView
            .findViewById<TextView>(
                R.id.title
            )
            .text = title

        // ============================================================
        // Surah / Ayah
        // ============================================================

        cardView
            .findViewById<TextView>(
                R.id.subtitle
            )
            .text = subtitle

        // ============================================================
        // Read Button
        // ============================================================

        cardView
            .findViewById<Button>(
                R.id.readButton
            )
            .setOnClickListener {

                Log.d(
                    "UnlockCard",
                    "✅ Read button clicked"
                )

                // Flutter هو Source of Truth.
                // Kotlin فقط يرسل Event إلى Flutter.

                MainActivity.notifyKhatmaRead()

                Log.d(
                    "UnlockCard",
                    "🚀 Khatma read sent to Flutter"
                )

                dismiss(app)
            }

        // ============================================================
        // Later Button
        // ============================================================

        cardView
            .findViewById<Button>(
                R.id.laterButton
            )
            .setOnClickListener {

                Log.d(
                    "UnlockCard",
                    "⏳ Later button clicked"
                )

                // لا نغير حالة الختمة.
                // نفس الآية ستظهر في الفتح القادم.

                dismiss(app)
            }

        // ============================================================
        // Window Params
        // ============================================================

        val params =
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                        WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                PixelFormat.TRANSLUCENT
            ).apply {

                gravity = Gravity.TOP
                y = 80
            }

        // ============================================================
        // Add Overlay
        // ============================================================

        try {

            windowManager.addView(
                cardView,
                params
            )

            view = cardView

            Log.d(
                "UnlockCard",
                "🔥🔥 Overlay added successfully"
            )

        } catch (e: Exception) {

            Log.e(
                "UnlockCard",
                "❌ Overlay addView FAILED",
                e
            )
        }
    }

// ================================================================
// Dismiss
// ================================================================

    fun dismiss(
        context: Context
    ) {
        handler.removeCallbacksAndMessages(null)

        view?.let { currentView ->

            val windowManager =
                context.getSystemService(
                    Context.WINDOW_SERVICE
                ) as WindowManager

            runCatching {

                windowManager.removeView(
                    currentView
                )

            }.onFailure { error ->

                Log.e(
                    "UnlockCard",
                    "❌ Failed to remove overlay",
                    error
                )
            }
        }

        view = null

        Log.d(
            "UnlockCard",
            "Overlay dismissed"
        )
    }

}
