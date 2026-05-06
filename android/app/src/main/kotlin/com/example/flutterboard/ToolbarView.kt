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
 * Samsung-style toolbar — 5 icons (no mic/voice):
 * Emoji | Sticker | GIF | Settings | More(···)
 *
 * Dark mode: circular container around each icon.
 * Light mode: flat icons.
 */
@SuppressLint("ViewConstructor")
class ToolbarView(
    private val ctx: Context,
    private val t: KeyboardTheme,
    private val h: Int,
    private val onEmoji: () -> Unit,
) : LinearLayout(ctx) {

    // 5 icons — no mic
    private val items = listOf(
        "☺"   to onEmoji,
        "⊞"   to {},
        "GIF" to {},
        "⚙"   to {},
        "···" to {},
    )

    init {
        orientation = HORIZONTAL
        gravity     = Gravity.CENTER_VERTICAL
        setBackgroundColor(t.toolbarBg)
        layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, h)
        items.forEach { (icon, action) -> addView(slot(icon, action)) }
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun slot(icon: String, action: () -> Unit): FrameLayout {
        val iconSizePx = dp(30)
        val fl = FrameLayout(ctx).apply {
            layoutParams = LayoutParams(0, h, 1f)
        }
        val container = FrameLayout(ctx).apply {
            layoutParams = FrameLayout.LayoutParams(iconSizePx, iconSizePx).also {
                it.gravity = Gravity.CENTER
            }
            if (t.isDark) {
                background = GradientDrawable().apply {
                    shape        = GradientDrawable.OVAL
                    setColor(android.graphics.Color.parseColor("#1C2B3A"))
                    setStroke(dp(1), android.graphics.Color.parseColor("#2A3D50"))
                }
            }
        }
        val tv = TextView(ctx).apply {
            text      = icon
            textSize  = if (icon.length > 1) 10f else 15f
            gravity   = Gravity.CENTER
            setTextColor(t.toolbarIcon)
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT)
        }
        container.addView(tv)
        fl.addView(container)
        fl.isHapticFeedbackEnabled = true
        fl.setOnClickListener {
            fl.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
            action()
        }
        return fl
    }

    private fun dp(v: Int) = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP, v.toFloat(), ctx.resources.displayMetrics).toInt()
}
