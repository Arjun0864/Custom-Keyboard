package com.example.flutterboard

import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.LayerDrawable

object DrawableUtils {

    fun key(color: Int, shadow: Int, r: Float, opacity: Float = 1f, hasShadow: Boolean = true): LayerDrawable {
        val c = applyOpacity(color, opacity)
        val sh = GradientDrawable().apply { setColor(shadow); cornerRadius = r }
        val fc = GradientDrawable().apply { setColor(c);      cornerRadius = r }
        return if (hasShadow) {
            LayerDrawable(arrayOf(sh, fc)).apply {
                setLayerInset(0, 0, 1, 0, 0)
                setLayerInset(1, 0, 0, 0, 1)
            }
        } else {
            LayerDrawable(arrayOf(fc))
        }
    }

    fun pressed(color: Int, shadow: Int, r: Float, opacity: Float = 1f, hasShadow: Boolean = true) =
        key(darken(color, 0.13f), shadow, r, opacity, hasShadow)

    private fun darken(c: Int, f: Float): Int {
        val r = (Color.red(c)   * (1f - f)).toInt().coerceIn(0, 255)
        val g = (Color.green(c) * (1f - f)).toInt().coerceIn(0, 255)
        val b = (Color.blue(c)  * (1f - f)).toInt().coerceIn(0, 255)
        return Color.rgb(r, g, b)
    }

    private fun applyOpacity(color: Int, opacity: Float): Int {
        if (opacity >= 1f) return color
        val a = (Color.alpha(color) * opacity).toInt().coerceIn(0, 255)
        return Color.argb(a, Color.red(color), Color.green(color), Color.blue(color))
    }
}
