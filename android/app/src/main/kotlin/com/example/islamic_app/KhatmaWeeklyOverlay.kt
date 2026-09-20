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

object KhatmaWeeklyOverlay {

    private const val TAG = "KhatmaWeekly"

    private var view: View? = null

    private val handler = Handler(Looper.getMainLooper())

    fun show(
        context: Context,
        totalAyahs: Int,
        weekNumber: Int
    ) {
        val app = context.applicationContext

        Log.d(
            TAG,
            "📊 Showing weekly report: total=$totalAyahs week=$weekNumber"
        )

        if (!Settings.canDrawOverlays(app)) {
            Log.e(TAG, "❌ Overlay permission NOT granted")
            return
        }

        dismiss(app)

        val windowManager =
            app.getSystemService(Context.WINDOW_SERVICE) as WindowManager

        val cardView =
            LayoutInflater.from(app).inflate(
                R.layout.overlay_khatma_weekly,
                null
            )

        val totalText =
            cardView.findViewById<TextView>(R.id.totalAyahs)

        val weekText =
            cardView.findViewById<TextView>(R.id.weekText)

        totalText.text = "$totalAyahs آية"

        weekText.text =
            if (weekNumber == 1) {
                "خلال أسبوع"
            } else {
                "خلال $weekNumber أسابيع"
            }

        cardView
            .findViewById<ImageButton>(R.id.closeButton)
            .setOnClickListener {

                Log.d(
                    TAG,
                    "❌ Weekly report closed"
                )

                dismiss(app)

                // بعد إغلاق التقرير نعرض آية الختمة
                showCurrentKhatmaAyah(app)
            }

        val params =
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                        WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.CENTER
            }

        try {

            windowManager.addView(
                cardView,
                params
            )

            view = cardView

            Log.d(
                TAG,
                "✅ Weekly report overlay added"
            )

        } catch (e: Exception) {

            Log.e(
                TAG,
                "❌ Failed to add weekly overlay",
                e
            )
        }
    }

    private fun showCurrentKhatmaAyah(
        context: Context
    ) {

        val prefs =
            context.getSharedPreferences(
                "khatma_unlock",
                Context.MODE_PRIVATE
            )

        val text =
            prefs.getString(
                "text",
                null
            )

        val surahName =
            prefs.getString(
                "surahName",
                null
            )

        val ayahNumber =
            prefs.getInt(
                "ayahNumber",
                0
            )

        if (
            text.isNullOrBlank() ||
            surahName.isNullOrBlank() ||
            ayahNumber <= 0
        ) {

            Log.d(
                TAG,
                "No khatma ayah synced"
            )

            return
        }

        Log.d(
            TAG,
            "📖 Showing Khatma Ayah " +
                    "surah=$surahName " +
                    "ayah=$ayahNumber"
        )

        PrayerCardOverlay.show(
            context,
            text,
            "$surahName • آية $ayahNumber"
        )
    }

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

            }.onFailure {

                Log.e(
                    TAG,
                    "❌ Failed to remove weekly overlay",
                    it
                )
            }
        }

        view = null

        Log.d(
            TAG,
            "Weekly report dismissed"
        )
    }
}