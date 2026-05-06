package com.example.flutterboard

import android.content.Context
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
import android.view.inputmethod.InputMethodManager
import android.widget.FrameLayout
import android.widget.LinearLayout

class FlutterBoardIME : InputMethodService() {

    private val st = KeyboardState()
    private lateinit var t: KeyboardTheme
    private lateinit var d: Dims

    // Suggestion bar hides after 1.5 s idle
    private val idleH = Handler(Looper.getMainLooper())
    private val idleR = Runnable { hideSuggestion() }

    private var root        : LinearLayout?      = null
    private var suggBar     : SuggestionBarView? = null   // above toolbar
    private var toolbar     : ToolbarView?       = null   // always visible
    private var rows        : LinearLayout?      = null
    private var emojiPanel  : EmojiPanelView?    = null
    private var emojiFrame  : FrameLayout?       = null   // overlays rows
    private var showingEmoji: Boolean            = false

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
            showingEmoji = false
        }
        rebuild()
        hideEmoji()
        hideSuggestion()
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

        val toolbarH = dp(44)
        val divider  = dp(1)
        val numRowH  = dp(36)
        val topPad   = dp(6)
        val keyGap   = dp(6)
        val rowGap   = dp(8)
        val edgePad  = dp(8)
        val botPad   = dp(24) + navBar   // extra space above nav bar

        val target   = (screenH * if (isLand) 0.50f else 0.38f).toInt()
        val overhead = toolbarH + divider + numRowH + topPad +
                (rowGap / 2) + (3 * rowGap) + botPad
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

        // ── Suggestion bar (hidden by default, slides in when typing) ──────────
        suggBar = SuggestionBarView(this, t, d.toolbarH) { word ->
            currentInputConnection?.commitText(word, 1)
            onKey()
        }.also {
            it.visibility = View.GONE
            root!!.addView(it, LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, d.toolbarH))
        }

        // ── Toolbar — ALWAYS visible ───────────────────────────────────────────
        toolbar = ToolbarView(this, t, d.toolbarH, onEmoji = { toggleEmoji() })
        root!!.addView(toolbar, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, d.toolbarH))

        // ── Divider ───────────────────────────────────────────────────────────
        root!!.addView(View(this).apply {
            setBackgroundColor(t.divider)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, dp(1))
        })

        // ── Key rows + emoji panel stacked in a FrameLayout ───────────────────
        emojiFrame = FrameLayout(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT)
        }

        rows = LinearLayout(this).apply {
            orientation  = LinearLayout.VERTICAL
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT)
        }
        emojiFrame!!.addView(rows)

        // Emoji panel (hidden by default)
        emojiPanel = EmojiPanelView(
            ctx     = this,
            t       = t,
            onEmoji = { emoji -> commit(emoji) },
            onBack  = { hideEmoji() },
        ).also {
            it.visibility = View.GONE
            emojiFrame!!.addView(it, FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT))
        }

        root!!.addView(emojiFrame)

        // ── Bottom spacer ─────────────────────────────────────────────────────
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
                onSpaceLongPress = ::showImePickerFromSpace,
            ).build()
        )
    }

    // ── Emoji panel ───────────────────────────────────────────────────────────

    private fun toggleEmoji() {
        if (showingEmoji) hideEmoji() else showEmoji()
    }

    private fun showEmoji() {
        showingEmoji = true
        rows?.visibility       = View.INVISIBLE
        emojiPanel?.visibility = View.VISIBLE
    }

    private fun hideEmoji() {
        showingEmoji = false
        emojiPanel?.visibility = View.GONE
        rows?.visibility       = View.VISIBLE
    }

    // ── Suggestion bar ────────────────────────────────────────────────────────

    private fun onKey() {
        suggBar?.next()
        idleH.removeCallbacks(idleR)
        showSuggestion()
        idleH.postDelayed(idleR, 1500L)
    }

    private fun showSuggestion() {
        suggBar?.visibility = View.VISIBLE
    }

    private fun hideSuggestion() {
        suggBar?.visibility = View.GONE
    }

    // ── Space long-press → IME picker ─────────────────────────────────────────

    private fun showImePickerFromSpace() {
        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
        imm?.showInputMethodPicker()
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
