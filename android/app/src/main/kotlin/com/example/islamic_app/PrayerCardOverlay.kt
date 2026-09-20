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
import android.widget.ImageButton
import android.widget.TextView

object PrayerCardOverlay {

    private const val TAG = "UnlockCard"

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

        val app =
            context.applicationContext

        Log.d(
            TAG,
            "🔥 PrayerCardOverlay.show()"
        )

        // ============================================================
        // Check Overlay Permission
        // ============================================================

        if (!Settings.canDrawOverlays(app)) {

            Log.e(
                TAG,
                "❌ Overlay permission NOT granted"
            )

            return
        }

        Log.d(
            TAG,
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
            LayoutInflater
                .from(app)
                .inflate(
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
        // Read Icon
        // ============================================================

        cardView
            .findViewById<ImageButton>(
                R.id.readButton
            )
            .setOnClickListener {

                Log.d(
                    TAG,
                    "✅ Read icon clicked"
                )

                // ====================================================
                // Flutter هو Source of Truth
                // ====================================================

                MainActivity.notifyKhatmaRead()

                Log.d(
                    TAG,
                    "🚀 Khatma read sent to Flutter"
                )

                dismiss(app)
            }

        // ============================================================
        // Later Icon
        // ============================================================

        cardView
            .findViewById<ImageButton>(
                R.id.laterButton
            )
            .setOnClickListener {

                Log.d(
                    TAG,
                    "⏳ Later icon clicked"
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
            )
                .apply {

                    // الكارد في منتصف الشاشة
                    gravity = Gravity.CENTER
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
                TAG,
                "🔥🔥 Overlay added successfully"
            )

        } catch (e: Exception) {

            Log.e(
                TAG,
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
                    TAG,
                    "❌ Failed to remove overlay",
                    error
                )
            }
        }

        view = null

        Log.d(
            TAG,
            "Overlay dismissed"
        )
    }
}