package com.example.islamic_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat

class UnlockService : Service() {

    private val receiver = UnlockReceiver()

    companion object {
        private const val TAG = "UnlockCard"

        private const val NOTIFICATION_ID = 1
        private const val NOTIFICATION_CHANNEL_ID =
            "unlock_service_quiet"

        const val ACTION_STOP =
            "com.example.islamic_app.STOP_UNLOCK_CARD"
    }

    override fun onCreate() {
        super.onCreate()

        Log.d(TAG, "Service onCreate")

        val type =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            } else {
                0
            }

        ServiceCompat.startForeground(
            this,
            NOTIFICATION_ID,
            buildNotification(),
            type
        )

        Log.d(TAG, "Foreground started")

        ContextCompat.registerReceiver(
            this,
            receiver,
            IntentFilter().apply {
                addAction(Intent.ACTION_USER_PRESENT)
                addAction(Intent.ACTION_SCREEN_OFF)
            },
            ContextCompat.RECEIVER_EXPORTED
        )

        Log.d(TAG, "Service started, receiver registered")
    }

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int
    ): Int {

        if (intent?.action == ACTION_STOP) {

            Log.d(
                TAG,
                "Stop button clicked from notification"
            )

            getSharedPreferences(
                "prayer_card",
                MODE_PRIVATE
            )
                .edit()
                .putBoolean("enabled", false)
                .apply()

            stopSelf()

            return START_NOT_STICKY
        }

        return START_STICKY
    }

    override fun onDestroy() {

        Log.d(TAG, "Service onDestroy")

        runCatching {
            unregisterReceiver(receiver)
        }

        PrayerCardOverlay.dismiss(this)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }

        super.onDestroy()

        Log.d(TAG, "Service destroyed")
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun buildNotification(): Notification {

        val notificationManager =
            getSystemService(
                NotificationManager::class.java
            )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            notificationManager.createNotificationChannel(
                NotificationChannel(
                    NOTIFICATION_CHANNEL_ID,
                    "آيات",
                    NotificationManager.IMPORTANCE_MIN
                ).apply {
                    description =
                        "خدمة آية عند فتح الهاتف"

                    setShowBadge(false)
                    enableVibration(false)
                    setSound(null, null)
                }
            )
        }

        return NotificationCompat.Builder(
            this,
            NOTIFICATION_CHANNEL_ID
        )
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("آيات")
            .setContentText(
                "خدمة آية عند فتح الهاتف"
            )
            .setPriority(
                NotificationCompat.PRIORITY_MIN
            )
            .setCategory(
                NotificationCompat.CATEGORY_SERVICE
            )
            .setOngoing(true)
            .setSilent(true)
            .setShowWhen(false)
            .setOnlyAlertOnce(true)
            .build()
    }}
