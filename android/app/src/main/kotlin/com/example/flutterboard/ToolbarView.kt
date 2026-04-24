package com.example.flutterboard

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.HapticFeedbackConstants
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Samsung-style toolbar.
 * Dark mode: circular icon buttons with subtle border ring.
 * Light mode: flat icon buttons, no circle bg.
 */
@SuppressLint("ViewConstructor")
class ToolbarView(
    private val ctx: Context,
    private val t: KeyboardTheme,
    private val h: Int,
) : LinearLayout(ctx) {

    // Samsung toolbar: emoji | sticker/clipboard | GIF | mic | settings | more
    private val icons = listOf("☺", "⊞", "GIF", "🎤", "⚙", "···")

    init {
        orientation = HORIZONTAL
        gravity     = Gravity.CENTER_VERTICAL
        setBackgroundColor(t.toolbarBg)
        layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, h)

        icons.forEach { icon ->
            addView(makeIconSlot(icon))
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun makeIconSlot(icon: String): FrameLayout {
        val slotSize = h  // square slot
        val iconSize = dp(28)

        val fl = FrameLayout(ctx).apply {
            layoutParams = LayoutParams(0, slotSize, 1f)
            gravity = Gravity.CENTER
        }

        // In dark mode: circular bg ring around icon (Samsung style)
        val iconContainer = FrameLayout(ctx).apply {
            val size = iconSize
            layoutParams = FrameLayout.LayoutParams(size, size).also {
                it.gravity = Gravity.CENTER
            }
            if (t.isDark) {
                background = GradientDrawable().apply {
                    shape        = GradientDrawable.OVAL
                    setColor(android.graphics.Color.parseColor("#1E2D3D"))
                    setStroke(dp(1), android.graphics.Color.parseColor("#2A3D50"))
                }
            }
        }

        val tv = TextView(ctx).apply {
            text      = icon
            textSize  = if (icon == "GIF" || icon == "···") 11f else 15f
            gravity   = Gravity.CENTER
            setTextColor(t.toolbarIcon)
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT)
        }

        iconContainer.addView(tv)
        fl.addView(iconContainer)

        fl.isHapticFeedbackEnabled = true
        fl.setOnClickListener {
            fl.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
        }

        return fl
    }

    private fun dp(v: Int) = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP, v.toFloat(), ctx.resources.displayMetrics).toInt()
}
