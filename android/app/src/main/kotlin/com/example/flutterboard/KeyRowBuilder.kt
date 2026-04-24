package com.example.flutterboard

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.HapticFeedbackConstants
import android.view.MotionEvent
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Builds all key rows.
 *
 * QWERTY structure (top → bottom):
 *   [1 2 3 4 5 6 7 8 9 0]  ← slim number-hint row, no key bg
 *   [Q W E R T Y U I O P]
 *   [  A S D F G H J K L  ] ← Samsung half-key offset
 *   [⇧  Z X C V B N M  ⌫]
 *   [!#1  ,  English(US)  .  ↵]
 */
@SuppressLint("ViewConstructor", "ClickableViewAccessibility")
class KeyRowBuilder(
    private val ctx  : Context,
    private val t    : KeyboardTheme,
    private val st   : KeyboardState,
    private val d    : Dims,
    private val onCommit  : (String) -> Unit,
    private val onBack    : () -> Unit,
    private val onEnter   : () -> Unit,
    private val onShift   : () -> Unit,
    private val onNumbers : () -> Unit,
    private val onSymbols : () -> Unit,
    private val onQwerty  : () -> Unit,
    private val enterLbl  : () -> String,
) {
    private val qRow1 = arrayOf("q","w","e","r","t","y","u","i","o","p")
    private val qRow2 = arrayOf("a","s","d","f","g","h","j","k","l")
    private val qRow3 = arrayOf("z","x","c","v","b","n","m")
    private val nums  = arrayOf("1","2","3","4","5","6","7","8","9","0")

    private val nRow1 = arrayOf("1","2","3","4","5","6","7","8","9","0")
    private val nRow2 = arrayOf("!","@","#","$","%","^","&","*","(",")")
    private val nRow3 = arrayOf("-","/",":",";","(",")","\$","&","@","\"")
    private val sRow1 = arrayOf("~","`","|","•","√","π","÷","×","¶","∆")
    private val sRow2 = arrayOf("£","¢","€","₹","^","°","=","{","}","\\")
    private val sRow3 = arrayOf("_","<",">","[","]","!","?","'","+","-")

    private val bsHandler  = Handler(Looper.getMainLooper())
    private var bsRunnable : Runnable? = null

    // ── Entry ─────────────────────────────────────────────────────────────────

    fun build(): LinearLayout = col().apply {
        setPadding(d.edgePad, d.topPad, d.edgePad, 0)
        when (st.layout) {
            KeyboardState.Layout.QWERTY -> {
                addView(numHintRow())
                addView(vGap(d.rowGap / 2))
                addView(letterRow(qRow1, d.keyH))
                addView(vGap())
                addView(row2())
                addView(vGap())
                addView(row3())
                addView(vGap())
                addView(bottomRow())
            }
            KeyboardState.Layout.NUMBERS -> {
                addView(letterRow(nRow1, d.keyH))
                addView(vGap())
                addView(letterRow(nRow2, d.keyH))
                addView(vGap())
                addView(symRow3(nRow3))
                addView(vGap())
                addView(symBottom())
            }
            KeyboardState.Layout.SYMBOLS -> {
                addView(letterRow(sRow1, d.keyH))
                addView(vGap())
                addView(letterRow(sRow2, d.keyH))
                addView(vGap())
                addView(symRow3(sRow3))
                addView(vGap())
                addView(symBottom())
            }
        }
    }

    // ── Rows ──────────────────────────────────────────────────────────────────

    /** Number row 1–0 with full key backgrounds (like Samsung dark mode) */
    private fun numHintRow(): LinearLayout {
        val row = row()
        nums.forEachIndexed { i, n ->
            if (i > 0) row.addView(hGap(d.numRowH))
            row.addView(key(n, d.numRowH, t.numKey, t.keyText, 1f, 13f) { onCommit(n) })
        }
        return row
    }

    private fun letterRow(keys: Array<String>, h: Int): LinearLayout {
        val row = row()
        keys.forEachIndexed { i, k ->
            if (i > 0) row.addView(hGap(h))
            val display = if (st.layout == KeyboardState.Layout.QWERTY)
                st.applyShift(k) else k
            row.addView(key(display, h, t.letterKey, t.keyText, 1f, 16f) { onCommit(k) })
        }
        return row
    }

    /** Row 2 — Samsung half-key offset on each side */
    private fun row2(): LinearLayout {
        val usable  = d.screenW - d.edgePad * 2
        val kw      = (usable - d.keyGap * 9).toFloat() / 10f
        val spacer  = (kw * 0.5f + d.keyGap * 0.5f).toInt()
        val row = LinearLayout(ctx).apply {
            orientation  = LinearLayout.HORIZONTAL
            gravity      = Gravity.CENTER_HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT)
        }
        row.addView(spacer(spacer, d.keyH))
        qRow2.forEachIndexed { i, k ->
            if (i > 0) row.addView(hGap(d.keyH))
            row.addView(key(st.applyShift(k), d.keyH, t.letterKey, t.keyText, 1f, 16f) { onCommit(k) })
        }
        row.addView(spacer(spacer, d.keyH))
        return row
    }

    /** Row 3 — [⇧ 1.5x] Z…M [⌫ 1.5x] */
    private fun row3(): LinearLayout {
        val row = row()
        row.addView(shiftKey())
        row.addView(hGap(d.keyH))
        qRow3.forEachIndexed { i, k ->
            if (i > 0) row.addView(hGap(d.keyH))
            row.addView(key(st.applyShift(k), d.keyH, t.letterKey, t.keyText, 1f, 16f) { onCommit(k) })
        }
        row.addView(hGap(d.keyH))
        row.addView(bsKey())
        return row
    }

    /**
     * Bottom row — Samsung exact proportions:
     * [!#1 1.5x] [, 1x] [English(US) 3.5x] [. 1x] [↵ 1.5x]
     */
    private fun bottomRow(): LinearLayout {
        val h = d.bottomH
        val row = row()
        row.addView(key("!#1", h, t.specialKey, t.keyText, 1.5f, 12f) { onNumbers() })
        row.addView(hGap(h))
        row.addView(key(",",   h, t.specialKey, t.keyText, 1.0f, 16f) { onCommit(",") })
        row.addView(hGap(h))
        row.addView(spaceKey(h, 3.5f))
        row.addView(hGap(h))
        row.addView(key(".",   h, t.specialKey, t.keyText, 1.0f, 16f) { onCommit(".") })
        row.addView(hGap(h))
        row.addView(enterKey(h, 1.5f))
        return row
    }

    private fun symRow3(keys: Array<String>): LinearLayout {
        val row = row()
        val lbl = if (st.layout == KeyboardState.Layout.SYMBOLS) "?123" else "#+="
        row.addView(key(lbl, d.keyH, t.specialKey, t.keyText, 1.5f, 11f) {
            if (st.layout == KeyboardState.Layout.SYMBOLS) onNumbers() else onSymbols()
        })
        row.addView(hGap(d.keyH))
        keys.forEachIndexed { i, k ->
            if (i > 0) row.addView(hGap(d.keyH))
            row.addView(key(k, d.keyH, t.letterKey, t.keyText, 1f, 14f) { onCommit(k) })
        }
        row.addView(hGap(d.keyH))
        row.addView(bsKey())
        return row
    }

    private fun symBottom(): LinearLayout {
        val h = d.bottomH
        val row = row()
        row.addView(key("ABC", h, t.specialKey, t.keyText, 1.5f, 12f) { onQwerty() })
        row.addView(hGap(h))
        row.addView(key("😊", h, t.specialKey, t.keyText, 1.0f, 16f) { onCommit("😊") })
        row.addView(hGap(h))
        row.addView(spaceKey(h, 3.5f))
        row.addView(hGap(h))
        row.addView(enterKey(h, 1.5f))
        return row
    }

    // ── Key factories ─────────────────────────────────────────────────────────

    private fun shiftKey(): View {
        val on  = st.shift != KeyboardState.Shift.OFF
        val bg  = if (on) t.shiftOn else t.specialKey
        val tc  = if (on) Color.WHITE else t.keyText
        val lbl = when (st.shift) {
            KeyboardState.Shift.CAPS -> "⇪"
            KeyboardState.Shift.ONCE -> "⬆"
            else                     -> "⇧"
        }
        return key(lbl, d.keyH, bg, tc, 1.5f, 18f) { onShift() }
    }

    private fun bsKey(): View {
        val fl = frame(t.specialKey, d.keyH, 1.5f)
        fl.addView(lbl("⌫", t.keyText, 18f))
        fl.setOnTouchListener { v, ev ->
            when (ev.action) {
                MotionEvent.ACTION_DOWN -> {
                    v.background = DrawableUtils.pressed(t.specialKey, t.shadow, d.radius)
                    v.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
                    onBack(); startBs()
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    v.background = DrawableUtils.key(t.specialKey, t.shadow, d.radius)
                    stopBs()
                }
            }
            true
        }
        return fl
    }

    private fun spaceKey(h: Int, w: Float): FrameLayout {
        val fl = frame(t.letterKey, h, w)
        // Dark mode: "< English (UK) >" with arrows, light: "English (US)"
        val spaceLabel = if (t.isDark) "< English (UK) >" else "English (US)"
        fl.addView(lbl(spaceLabel, t.spaceText, 11f))
        fl.setOnTouchListener { v, ev ->
            when (ev.action) {
                MotionEvent.ACTION_DOWN -> {
                    v.background = DrawableUtils.pressed(t.letterKey, t.shadow, d.radius)
                    v.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
                }
                MotionEvent.ACTION_UP -> {
                    v.background = DrawableUtils.key(t.letterKey, t.shadow, d.radius)
                    onCommit(" ")
                }
                MotionEvent.ACTION_CANCEL ->
                    v.background = DrawableUtils.key(t.letterKey, t.shadow, d.radius)
            }
            true
        }
        return fl
    }

    private fun enterKey(h: Int, w: Float): View {
        val label = enterLbl()
        val sp    = when { label.length >= 4 -> 11f; label.length == 3 -> 12f; else -> 15f }
        return key(label, h, t.enterBg, t.enterText, w, sp) { onEnter() }
    }

    private fun key(
        label: String, h: Int, bg: Int, tc: Int,
        w: Float, sp: Float, action: () -> Unit
    ): View {
        val fl = frame(bg, h, w)
        fl.addView(lbl(label, tc, sp))
        fl.setOnTouchListener { v, ev ->
            when (ev.action) {
                MotionEvent.ACTION_DOWN -> {
                    v.background = DrawableUtils.pressed(bg, t.shadow, d.radius)
                    v.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
                }
                MotionEvent.ACTION_UP -> {
                    v.background = DrawableUtils.key(bg, t.shadow, d.radius)
                    action()
                }
                MotionEvent.ACTION_CANCEL ->
                    v.background = DrawableUtils.key(bg, t.shadow, d.radius)
            }
            true
        }
        return fl
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private fun frame(bg: Int, h: Int, w: Float) = FrameLayout(ctx).apply {
        layoutParams = LinearLayout.LayoutParams(0, h, w)
        background   = DrawableUtils.key(bg, t.shadow, d.radius)
    }

    private fun lbl(text: String, color: Int, sp: Float) = TextView(ctx).apply {
        this.text    = text
        textSize     = sp
        gravity      = Gravity.CENTER
        typeface     = Typeface.create("sans-serif", Typeface.NORMAL)
        setTextColor(color)
        layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT)
    }

    private fun col() = LinearLayout(ctx).apply {
        orientation  = LinearLayout.VERTICAL
        layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT)
    }

    private fun row() = LinearLayout(ctx).apply {
        orientation  = LinearLayout.HORIZONTAL
        gravity      = Gravity.CENTER_VERTICAL
        layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT)
    }

    private fun hGap(h: Int) = View(ctx).apply {
        layoutParams = LinearLayout.LayoutParams(d.keyGap, h)
    }

    private fun vGap(h: Int = d.rowGap) = View(ctx).apply {
        layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, h)
    }

    private fun spacer(w: Int, h: Int) = View(ctx).apply {
        layoutParams = LinearLayout.LayoutParams(w, h)
    }

    private fun startBs() {
        bsRunnable = object : Runnable {
            override fun run() { onBack(); bsHandler.postDelayed(this, 80) }
        }
        bsHandler.postDelayed(bsRunnable!!, 400)
    }

    fun stopBs() {
        bsRunnable?.let { bsHandler.removeCallbacks(it) }
        bsRunnable = null
    }
}
