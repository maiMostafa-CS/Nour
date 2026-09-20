package com.example.islamic_app

import android.content.Context
import kotlin.random.Random

data class Verse(val text: String, val ref: String)

object VerseProvider {

    private val verses = listOf(
        Verse("﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾", "سورة الرعد • الآية 28"),
        Verse("﴿فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا﴾", "سورة الشرح • الآيتان 5-6"),
        Verse("﴿وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا﴾", "سورة الطلاق • الآية 2"),
        Verse("﴿وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ﴾", "سورة الضحى • الآية 5"),
        Verse("﴿إِنَّ اللَّهَ مَعَ الصَّابِرِينَ﴾", "سورة البقرة • الآية 153"),
        Verse("﴿فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ﴾", "سورة البقرة • الآية 152"),
        Verse("﴿وَقُل رَّبِّ زِدْنِي عِلْمًا﴾", "سورة طه • الآية 114"),
        Verse("﴿حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ﴾", "سورة آل عمران • الآية 173"),
    )

    fun next(context: Context): Verse {
        val prefs = context.getSharedPreferences("prayer_card", Context.MODE_PRIVATE)
        val last = prefs.getInt("last_verse", -1)

        var i: Int
        do {
            i = Random.nextInt(verses.size)
        } while (i == last && verses.size > 1)

        prefs.edit().putInt("last_verse", i).apply()
        return verses[i]
    }
}