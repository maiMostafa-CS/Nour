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

    override fun onReceive(
        context: Context,
        intent: Intent
    ) {
        val app = context.applicationContext

        Log.d(
            "UnlockCard",
            "🔥 RECEIVER RECEIVED: ${intent.action}"
        )

        when (intent.action) {

            Intent.ACTION_SCREEN_OFF -> {

                Log.d(
                    "UnlockCard",
                    "SCREEN_OFF -> dismiss"
                )

                handler.removeCallbacksAndMessages(null)

                PrayerCardOverlay.dismiss(app)
            }

            Intent.ACTION_USER_PRESENT -> {

                Log.d(
                    "UnlockCard",
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
                    "UnlockCard",
                    "USER_PRESENT " +
                            "interactive=${pm.isInteractive}, " +
                            "locked=${km.isKeyguardLocked}"
                )

                handler.removeCallbacksAndMessages(null)

                handler.postDelayed({

                    val interactive = pm.isInteractive
                    val locked = km.isKeyguardLocked

                    Log.d(
                        "UnlockCard",
                        "After delay: " +
                                "interactive=$interactive " +
                                "locked=$locked"
                    )

                    if (!interactive || locked) {

                        Log.d(
                            "UnlockCard",
                            "Skipped: screen off or still locked"
                        )

                        return@postDelayed
                    }

                    showCurrentKhatmaAyah(app)

                }, 400)
            }
        }
    }

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
                "UnlockCard",
                "No khatma ayah synced"
            )

            return
        }

        Log.d(
            "UnlockCard",
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
}