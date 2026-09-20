package com.example.islamic_app.khatma

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class KhatmaUnlockReceiver(
    private val onUnlock: () -> Unit
) : BroadcastReceiver() {

    override fun onReceive(
        context: Context,
        intent: Intent
    ) {
        if (Intent.ACTION_USER_PRESENT == intent.action) {
            onUnlock()
        }
    }
}