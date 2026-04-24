package com.example.flutterboard

import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.LayerDrawable

object DrawableUtils {

    fun key(color: Int, shadow: Int, r: Float): LayerDrawable {
        val sh = GradientDrawable().apply { setColor(shadow); cornerRadius = r }
        val fc = GradientDrawable().apply { setColor(color);  cornerRadius = r }
        return LayerDrawable(arrayOf(sh, fc)).apply {
            setLayerInset(0, 0, 1, 0, 0)
            setLayerInset(1, 0, 0, 0, 1)
        }
    }

    fun pressed(color: Int, shadow: Int, r: Float) =
        key(darken(color, 0.13f), shadow, r)

    private fun darken(c: Int, f: Float): Int {
        val r = (android.graphics.Color.red(c)   * (1f - f)).toInt().coerceIn(0, 255)
        val g = (android.graphics.Color.green(c) * (1f - f)).toInt().coerceIn(0, 255)
        val b = (android.graphics.Color.blue(c)  * (1f - f)).toInt().coerceIn(0, 255)
        return android.graphics.Color.rgb(r, g, b)
    }
}
