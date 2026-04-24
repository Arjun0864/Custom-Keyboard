package com.example.flutterboard

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Typeface
import android.util.TypedValue
import android.view.Gravity
import android.view.HapticFeedbackConstants
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView

@SuppressLint("ViewConstructor")
class SuggestionBarView(
    private val ctx: Context,
    private val t: KeyboardTheme,
    private val h: Int,
    private val onTap: (String) -> Unit,
) : LinearLayout(ctx) {

    private val slots = mutableListOf<TextView>()
    private val pool  = listOf(
        listOf("the","and","for"),
        listOf("I","it","is"),
        listOf("you","are","was"),
        listOf("that","he","she"),
        listOf("on","in","at"),
    )
    private var idx = 0

    init {
        orientation = HORIZONTAL
        gravity     = Gravity.CENTER_VERTICAL
        setBackgroundColor(t.suggBg)
        layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, h)

        repeat(3) { i ->
            if (i > 0) addView(divider())
            val tv = slot(i == 1)
            slots.add(tv)
            addView(tv)
        }
        push(pool[0])
    }

    fun next() { idx = (idx + 1) % pool.size; push(pool[idx]) }

    private fun push(words: List<String>) {
        slots.forEachIndexed { i, tv ->
            val w = words.getOrElse(i) { "" }
            tv.text = w
            tv.setOnClickListener {
                if (w.isNotEmpty()) {
                    tv.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
                    onTap(w)
                }
            }
        }
    }

    private fun slot(bold: Boolean) = TextView(ctx).apply {
        textSize  = 14f
        gravity   = Gravity.CENTER
        typeface  = if (bold) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
        setTextColor(if (bold) t.suggCenter else t.suggSide)
        layoutParams = LayoutParams(0, h, 1f)
    }

    private fun divider() = View(ctx).apply {
        setBackgroundColor(t.suggDivider)
        val dp20 = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP, 20f, ctx.resources.displayMetrics).toInt()
        layoutParams = LayoutParams(
            TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 1f,
                ctx.resources.displayMetrics).toInt(),
            dp20
        ).also { it.gravity = Gravity.CENTER_VERTICAL }
    }
}
