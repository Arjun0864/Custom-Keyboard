package com.example.flutterboard

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.content.res.Configuration
import android.inputmethodservice.InputMethodService
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.view.View
import android.view.ViewGroup
import android.view.WindowInsets
import android.view.inputmethod.EditorInfo
import android.widget.FrameLayout
import android.widget.LinearLayout

class FlutterBoardIME : InputMethodService() {

    private val st = KeyboardState()
    private lateinit var t: KeyboardTheme
    private lateinit var d: Dims

    private val idleH = Handler(Looper.getMainLooper())
    private val idleR = Runnable { setTyping(false) }

    private var root    : LinearLayout?      = null
    private var topFrame: FrameLayout?       = null
    private var toolbar : ToolbarView?       = null
    private var suggest : SuggestionBarView? = null
    private var rows    : LinearLayout?      = null

    // ── IME ───────────────────────────────────────────────────────────────────

    override fun isFullscreenMode(): Boolean = false

    override fun onCreateInputView(): View {
        t = KeyboardTheme.resolve(this)
        d = computeDims()
        buildRoot()
        return root!!
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        if (!restarting) {
            st.shift  = KeyboardState.Shift.OFF
            st.layout = KeyboardState.Layout.QWERTY
            setTyping(false)
        }
        rebuild()
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        t = KeyboardTheme.resolve(this)
        d = computeDims()
        buildRoot()
    }

    override fun onDestroy() {
        idleH.removeCallbacks(idleR)
        super.onDestroy()
    }

    // ── Dimensions ────────────────────────────────────────────────────────────

    private fun computeDims(): Dims {
        // Try to get accurate nav bar height from window insets
        val navBar = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val h = window?.window?.decorView
                ?.rootWindowInsets
                ?.getInsets(WindowInsets.Type.navigationBars())?.bottom ?: 0
            if (h > 0) h else fallbackNavBar()
        } else fallbackNavBar()

        val dm      = resources.displayMetrics
        val screenH = dm.heightPixels
        val screenW = dm.widthPixels
        val isLand  = resources.configuration.orientation ==
                Configuration.ORIENTATION_LANDSCAPE

        fun dp(v: Int) = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP, v.toFloat(), dm).toInt()

        val toolbarH = dp(40)
        val divider  = dp(1)
        val numRowH  = dp(32)
        val topPad   = dp(6)
        val keyGap   = dp(6)
        val rowGap   = dp(8)
        val edgePad  = dp(8)
        val botPad   = dp(20) + navBar   // increased: more space above nav bar arrow

        val target   = (screenH * if (isLand) 0.50f else 0.37f).toInt()

        // overhead = toolbar + divider + numRow + topPad
        //          + (rowGap/2 after numRow) + 3*rowGap + botPad
        val overhead = toolbarH + divider + numRowH + topPad +
                (rowGap / 2) + (3 * rowGap) + botPad

        // 4 rows: 3 letter + 1 bottom (bottomH = keyH + dp(6))
        // target = overhead + 4*keyH + dp(6)
        val keyH    = ((target - overhead - dp(6)) / 4).coerceIn(dp(42), dp(54))
        val bottomH = keyH + dp(6)

        return Dims(
            toolbarH = toolbarH,
            numRowH  = numRowH,
            keyH     = keyH,
            bottomH  = bottomH,
            keyGap   = keyGap,
            rowGap   = rowGap,
            edgePad  = edgePad,
            topPad   = topPad,
            botPad   = botPad,
            radius   = dp(8).toFloat(),
            navBarPx = navBar,
            screenW  = screenW,
        )
    }

    private fun fallbackNavBar(): Int {
        val id = resources.getIdentifier("navigation_bar_height", "dimen", "android")
        return if (id > 0) resources.getDimensionPixelSize(id) else 0
    }

    // ── Build ─────────────────────────────────────────────────────────────────

    private fun buildRoot() {
        root = LinearLayout(this).apply {
            orientation  = LinearLayout.VERTICAL
            setBackgroundColor(t.bg)
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT)
        }

        // Top bar — toolbar and suggestion bar in a FrameLayout
        topFrame = FrameLayout(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, d.toolbarH)
        }
        toolbar = ToolbarView(this, t, d.toolbarH)
        suggest = SuggestionBarView(this, t, d.toolbarH) { word ->
            currentInputConnection?.commitText(word, 1)
            onKey()
        }
        topFrame!!.addView(toolbar,
            FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, d.toolbarH))
        topFrame!!.addView(suggest,
            FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, d.toolbarH))
        suggest!!.alpha      = 0f
        suggest!!.visibility = View.INVISIBLE
        root!!.addView(topFrame)

        // Divider
        root!!.addView(View(this).apply {
            setBackgroundColor(t.divider)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, dp(1))
        })

        // Key rows
        rows = LinearLayout(this).apply {
            orientation  = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT)
        }
        root!!.addView(rows)

        // Bottom spacer — clears nav bar
        root!!.addView(View(this).apply {
            setBackgroundColor(t.bg)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, d.botPad)
        })

        rebuild()
    }

    private fun rebuild() {
        rows?.removeAllViews()
        rows?.addView(
            KeyRowBuilder(
                ctx      = this,
                t        = t,
                st       = st,
                d        = d,
                onCommit = ::commit,
                onBack   = ::backspace,
                onEnter  = ::enter,
                onShift  = { st.cycleShift(); rebuild() },
                onNumbers= { st.layout = KeyboardState.Layout.NUMBERS; rebuild() },
                onSymbols= { st.layout = KeyboardState.Layout.SYMBOLS; rebuild() },
                onQwerty = { st.layout = KeyboardState.Layout.QWERTY;  rebuild() },
                enterLbl = ::enterLabel,
            ).build()
        )
    }

    // ── Typing state ──────────────────────────────────────────────────────────

    private fun onKey() {
        suggest?.next()
        idleH.removeCallbacks(idleR)
        if (!st.typing) setTyping(true)
        idleH.postDelayed(idleR, 1500L)
    }

    private fun setTyping(on: Boolean) {
        if (st.typing == on) return
        st.typing = on
        val show = if (on) suggest  else toolbar
        val hide = if (on) toolbar  else suggest
        show ?: return; hide ?: return
        show.visibility = View.VISIBLE
        show.animate().alpha(1f).setDuration(150).start()
        hide.animate().alpha(0f).setDuration(150)
            .setListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(a: Animator) {
                    hide.visibility = View.INVISIBLE
                }
            }).start()
    }

    // ── Input ─────────────────────────────────────────────────────────────────

    private fun commit(k: String) {
        currentInputConnection?.commitText(st.applyShift(k), 1)
        st.afterChar(); rebuild(); onKey()
    }

    private fun backspace() {
        val ic  = currentInputConnection ?: return
        val sel = try { ic.getSelectedText(0) } catch (_: Exception) { null }
        if (!sel.isNullOrEmpty()) ic.commitText("", 1)
        else ic.deleteSurroundingText(1, 0)
        onKey()
    }

    private fun enter() {
        val ic   = currentInputConnection ?: return
        val info = currentInputEditorInfo
        if (info != null) {
            val act = info.imeOptions and EditorInfo.IME_MASK_ACTION
            if (act != EditorInfo.IME_ACTION_NONE &&
                act != EditorInfo.IME_ACTION_UNSPECIFIED) {
                ic.performEditorAction(act); onKey(); return
            }
        }
        ic.commitText("\n", 1); onKey()
    }

    private fun enterLabel(): String {
        val info = currentInputEditorInfo ?: return "↵"
        return when (info.imeOptions and EditorInfo.IME_MASK_ACTION) {
            EditorInfo.IME_ACTION_SEARCH -> "🔍"
            EditorInfo.IME_ACTION_SEND   -> "Send"
            EditorInfo.IME_ACTION_GO     -> "Go"
            EditorInfo.IME_ACTION_DONE   -> "Done"
            EditorInfo.IME_ACTION_NEXT   -> "Next"
            else                         -> "↵"
        }
    }

    private fun dp(v: Int) = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP, v.toFloat(), resources.displayMetrics).toInt()
}
