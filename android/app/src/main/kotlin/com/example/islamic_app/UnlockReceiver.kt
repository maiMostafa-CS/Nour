package com.example.islamic_app

import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.util.Log

class UnlockReceiver : BroadcastReceiver() {

    private val handler = Handler(Looper.getMainLooper())

    companion object {
        private const val TAG = "UnlockCard"

        private const val KHATMA_WEEKLY_PREFS = "khatma_weekly"

        // آخر أسبوع تم عرض تقريره
        private const val LAST_SHOWN_WEEK_KEY = "last_shown_week"
    }

    override fun onReceive(
        context: Context,
        intent: Intent
    ) {
        val app = context.applicationContext

        Log.d(
            TAG,
            "🔥 RECEIVER RECEIVED: ${intent.action}"
        )

        when (intent.action) {

            Intent.ACTION_SCREEN_OFF -> {

                Log.d(
                    TAG,
                    "SCREEN_OFF -> dismiss"
                )

                handler.removeCallbacksAndMessages(null)

                PrayerCardOverlay.dismiss(app)
                KhatmaWeeklyOverlay.dismiss(app)
            }

            Intent.ACTION_USER_PRESENT -> {

                Log.d(
                    TAG,
                    "🔥 USER_PRESENT RECEIVED"
                )

                val pm =
                    app.getSystemService(
                        Context.POWER_SERVICE
                    ) as PowerManager

                val km =
                    app.getSystemService(
                        Context.KEYGUARD_SERVICE
                    ) as KeyguardManager

                Log.d(
                    TAG,
                    "USER_PRESENT " +
                            "interactive=${pm.isInteractive}, " +
                            "locked=${km.isKeyguardLocked}"
                )

                handler.removeCallbacksAndMessages(null)

                handler.postDelayed({

                    val interactive = pm.isInteractive
                    val locked = km.isKeyguardLocked

                    Log.d(
                        TAG,
                        "After delay: " +
                                "interactive=$interactive " +
                                "locked=$locked"
                    )

                    if (!interactive || locked) {

                        Log.d(
                            TAG,
                            "Skipped: screen off or still locked"
                        )

                        return@postDelayed
                    }

                    // نتحقق أولاً من التقرير الأسبوعي.
                    // لو فيه تقرير جديد، يظهر هو أولاً.
                    val weeklyShown =
                        showWeeklyReportIfNeeded(app)

                    // لو مفيش تقرير جديد، نعرض آية الختمة مباشرة.
                    if (!weeklyShown) {
                        showCurrentKhatmaAyah(app)
                    }

                }, 400)
            }
        }
    }

    // =========================================================
    // كارد الآية الحالي
    // =========================================================

    private fun showCurrentKhatmaAyah(
        context: Context
    ) {

        val prefs = context.getSharedPreferences(
            "khatma_unlock",
            Context.MODE_PRIVATE
        )

        val text = prefs.getString(
            "text",
            null
        )

        val surahName = prefs.getString(
            "surahName",
            null
        )

        val ayahNumber = prefs.getInt(
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
            "🔥 Showing Khatma Ayah " +
                    "surah=$surahName " +
                    "ayah=$ayahNumber"
        )

        PrayerCardOverlay.show(
            context,
            text,
            "$surahName • آية $ayahNumber"
        )
    }

    // =========================================================
    // كارد التقرير الأسبوعي
    // =========================================================

    private fun showWeeklyReportIfNeeded(
        context: Context
    ): Boolean {

        val prefs = context.getSharedPreferences(
            KHATMA_WEEKLY_PREFS,
            Context.MODE_PRIVATE
        )

        val totalAyahs = prefs.getInt(
            "totalAyahs",
            0
        )

        val weekNumber = prefs.getInt(
            "weekNumber",
            0
        )

        val lastShownWeek = prefs.getInt(
            LAST_SHOWN_WEEK_KEY,
            0
        )

        Log.d(
            TAG,
            "📊 Weekly report check: " +
                    "total=$totalAyahs " +
                    "week=$weekNumber " +
                    "lastShown=$lastShownWeek"
        )

        // لا يوجد تقرير
        if (totalAyahs <= 0 || weekNumber <= 0) {

            Log.d(
                TAG,
                "📊 No weekly report available"
            )

            return false
        }

        // التقرير تم عرضه بالفعل
        if (weekNumber <= lastShownWeek) {

            Log.d(
                TAG,
                "📊 Weekly report already shown"
            )

            return false
        }

        Log.d(
            TAG,
            "📊 Showing NEW weekly report"
        )

        KhatmaWeeklyOverlay.show(
            context = context,
            totalAyahs = totalAyahs,
            weekNumber = weekNumber
        )

        prefs.edit()
            .putInt(
                LAST_SHOWN_WEEK_KEY,
                weekNumber
            )
            .apply()

        Log.d(
            TAG,
            "✅ Weekly report marked as shown: week=$weekNumber"
        )

        return true
    }
}