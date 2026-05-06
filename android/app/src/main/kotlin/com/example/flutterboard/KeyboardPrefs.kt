package com.example.flutterboard

import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color

/**
 * Reads settings saved by the Flutter ThemeProvider (SharedPreferences).
 * Keys must match exactly what ThemeProvider writes.
 */
object KeyboardPrefs {

    private fun prefs(ctx: Context): SharedPreferences =
        ctx.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    // Flutter stores keys with "flutter." prefix in FlutterSharedPreferences
    private fun get(ctx: Context, key: String): Any? =
        prefs(ctx).all["flutter.$key"]

    fun isDark(ctx: Context): Boolean {
        val mode = (get(ctx, "colorMode") as? Long)?.toInt() ?: 0
        return when (mode) {
            1    -> true   // dark
            2    -> isSystemDark(ctx)  // auto
            else -> false  // light
        }
    }

    fun accentColor(ctx: Context): Int {
        val hex = get(ctx, "customColorHex") as? String ?: "#007AFF"
        return try {
            Color.parseColor(hex)
        } catch (_: Exception) {
            Color.parseColor("#007AFF")
        }
    }

    fun keyBorderRadius(ctx: Context): Float {
        val r = (get(ctx, "keyBorderRadius") as? Double)?.toFloat() ?: 8f
        return r.coerceIn(0f, 20f)
    }

    fun keyGapSpacing(ctx: Context): Int {
        val gap = (get(ctx, "keyGapSpacing") as? Double)?.toFloat() ?: 6f
        val dm = ctx.resources.displayMetrics
        return (gap * dm.density).toInt()
    }

    fun keyShadow(ctx: Context): Boolean =
        get(ctx, "keyShadow") as? Boolean ?: true

    fun fontSize(ctx: Context): Float {
        val f = (get(ctx, "fontSize") as? Double)?.toFloat() ?: 16f
        return f.coerceIn(12f, 20f)
    }

    fun keyOpacity(ctx: Context): Float {
        val o = (get(ctx, "keyOpacity") as? Double)?.toFloat() ?: 1f
        return o.coerceIn(0.3f, 1f)
    }

    private fun isSystemDark(ctx: Context): Boolean {
        val uiMode = ctx.resources.configuration.uiMode and
                android.content.res.Configuration.UI_MODE_NIGHT_MASK
        return uiMode == android.content.res.Configuration.UI_MODE_NIGHT_YES
    }
}
