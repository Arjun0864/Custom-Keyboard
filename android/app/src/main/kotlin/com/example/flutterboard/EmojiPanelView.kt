package com.example.flutterboard

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.util.TypedValue
import android.view.Gravity
import android.view.HapticFeedbackConstants
import android.view.View
import android.widget.*

/**
 * Full emoji panel — same height as keyboard rows area.
 * Tabs: Recent | Smileys | People | Animals | Food | Travel | Objects | Symbols
 */
@SuppressLint("ViewConstructor", "ClickableViewAccessibility")
class EmojiPanelView(
    private val ctx: Context,
    private val t: KeyboardTheme,
    private val onEmoji: (String) -> Unit,
    private val onBack: () -> Unit,
) : LinearLayout(ctx) {

    private val categories = listOf(
        "🕐" to listOf("😀","😃","😄","😁","😆","😅","🤣","😂","🙂","🙃","😉","😊","😇","🥰","😍","🤩","😘","😗","😚","😙","🥲","😋","😛","😜","🤪","😝","🤑","🤗","🤭","🤫","🤔","🤐","🤨","😐","😑","😶","😏","😒","🙄","😬","🤥","😌","😔","😪","🤤","😴","😷","🤒","🤕","🤢","🤮","🤧","🥵","🥶","🥴","😵","🤯","🤠","🥳","🥸","😎","🤓","🧐"),
        "😊" to listOf("😀","😃","😄","😁","😆","😅","🤣","😂","🙂","🙃","😉","😊","😇","🥰","😍","🤩","😘","😗","😚","😙","🥲","😋","😛","😜","🤪","😝","🤑","🤗","🤭","🤫","🤔","🤐","🤨","😐","😑","😶","😏","😒","🙄","😬","🤥","😌","😔","😪","🤤","😴","😷","🤒","🤕","🤢","🤮","🤧","🥵","🥶","🥴","😵","🤯","🤠","🥳","🥸","😎","🤓","🧐"),
        "👋" to listOf("👋","🤚","🖐","✋","🖖","👌","🤌","🤏","✌","🤞","🤟","🤘","🤙","👈","👉","👆","🖕","👇","☝","👍","👎","✊","👊","🤛","🤜","👏","🙌","👐","🤲","🤝","🙏","✍","💅","🤳","💪","🦾","🦵","🦶","👂","🦻","👃","🧠","🦷","🦴","👀","👁","👅","👄","💋","🩸"),
        "🐶" to listOf("🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐨","🐯","🦁","🐮","🐷","🐸","🐵","🙈","🙉","🙊","🐔","🐧","🐦","🐤","🦆","🦅","🦉","🦇","🐺","🐗","🐴","🦄","🐝","🐛","🦋","🐌","🐞","🐜","🦟","🦗","🕷","🦂","🐢","🐍","🦎","🦖","🦕","🐙","🦑","🦐","🦞","🦀","🐡","🐠","🐟","🐬","🐳","🐋","🦈"),
        "🍕" to listOf("🍎","🍐","🍊","🍋","🍌","🍉","🍇","🍓","🫐","🍒","🍑","🥭","🍍","🥥","🥝","🍅","🍆","🥑","🥦","🥬","🥒","🌶","🫑","🧄","🧅","🥔","🍠","🥐","🥯","🍞","🥖","🥨","🧀","🥚","🍳","🧈","🥞","🧇","🥓","🥩","🍗","🍖","🌭","🍔","🍟","🍕","🫓","🥪","🥙","🧆","🌮","🌯","🫔","🥗","🥘","🫕","🥫","🍝","🍜","🍲","🍛","🍣","🍱","🥟","🍤","🍙","🍚","🍘","🍥","🥮","🍢","🧁","🍰","🎂","🍮","🍭","🍬","🍫","🍿","🍩","🍪"),
        "⚽" to listOf("⚽","🏀","🏈","⚾","🥎","🎾","🏐","🏉","🥏","🎱","🏓","🏸","🏒","🏑","🥍","🏏","🪃","🥅","⛳","🪁","🏹","🎣","🤿","🥊","🥋","🎽","🛹","🛼","🛷","⛸","🥌","🎿","⛷","🏂","🪂","🏋","🤼","🤸","⛹","🤺","🏇","🧘","🏄","🏊","🤽","🚣","🧗","🚵","🚴","🏆","🥇","🥈","🥉","🏅","🎖","🏵","🎗","🎫","🎟","🎪","🤹","🎭","🩰","🎨","🎬","🎤","🎧","🎼","🎵","🎶","🎹","🥁","🪘","🎷","🎺","🎸","🪕","🎻","🎲","♟","🎯","🎳","🎮","🎰","🧩"),
        "💡" to listOf("💡","🔦","🕯","🪔","🧯","💸","💵","💴","💶","💷","🪙","💰","💳","💎","⚖","🪜","🧰","🪛","🔧","🔨","⚒","🛠","⛏","🪚","🔩","🪤","🧲","🔫","💣","🪓","🔪","🗡","⚔","🛡","🪃","🏹","🪝","🧱","🪞","🪟","🛏","🛋","🪑","🚽","🪠","🚿","🛁","🪤","🧴","🧷","🧹","🧺","🧻","🪣","🧼","🫧","🪥","🧽","🛒","🚪","📱","💻","⌨","🖥","🖨","🖱","🖲","🕹","🗜","💽","💾","💿","📀","📼","📷","📸","📹","🎥","📽","🎞","📞","☎","📟","📠","📺","📻","🧭","⏱","⏲","⏰","🕰","⌛","⏳","📡","🔋","🪫","🔌"),
        "❤️" to listOf("❤","🧡","💛","💚","💙","💜","🖤","🤍","🤎","💔","❤‍🔥","❤‍🩹","❣","💕","💞","💓","💗","💖","💘","💝","💟","☮","✝","☪","🕉","☸","✡","🔯","🕎","☯","☦","🛐","⛎","♈","♉","♊","♋","♌","♍","♎","♏","♐","♑","♒","♓","🆔","⚛","🉑","☢","☣","📴","📳","🈶","🈚","🈸","🈺","🈷","✴","🆚","💮","🉐","㊙","㊗","🈴","🈵","🈹","🈲","🅰","🅱","🆎","🆑","🅾","🆘","❌","⭕","🛑","⛔","📛","🚫","💯","💢","♨","🚷","🚯","🚳","🚱","🔞","📵","🚭","❗","❕","❓","❔","‼","⁉"),
    )

    private var selectedCat = 0
    private lateinit var gridContainer: FrameLayout
    private lateinit var tabRow: LinearLayout

    init {
        orientation = VERTICAL
        setBackgroundColor(t.bg)
        layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        buildUI()
    }

    private fun buildUI() {
        // Tab row
        tabRow = LinearLayout(ctx).apply {
            orientation = HORIZONTAL
            setBackgroundColor(t.toolbarBg)
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, dp(40))
        }
        categories.forEachIndexed { i, (icon, _) ->
            tabRow.addView(makeTab(icon, i))
        }
        // Back button on right
        tabRow.addView(TextView(ctx).apply {
            text      = "⌨"
            textSize  = 16f
            gravity   = Gravity.CENTER
            setTextColor(t.toolbarIcon)
            layoutParams = LayoutParams(dp(44), dp(40))
            setOnClickListener { onBack() }
        })
        addView(tabRow)

        // Divider
        addView(View(ctx).apply {
            setBackgroundColor(t.divider)
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, dp(1))
        })

        // Grid container
        gridContainer = FrameLayout(ctx).apply {
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, 0, 1f)
        }
        addView(gridContainer)

        refreshGrid()
        highlightTab(0)
    }

    private fun makeTab(icon: String, idx: Int): TextView {
        return TextView(ctx).apply {
            text      = icon
            textSize  = 18f
            gravity   = Gravity.CENTER
            setTextColor(t.toolbarIcon)
            layoutParams = LayoutParams(0, dp(40), 1f)
            setOnClickListener {
                selectedCat = idx
                refreshGrid()
                highlightTab(idx)
            }
        }
    }

    private fun highlightTab(selected: Int) {
        for (i in 0 until tabRow.childCount - 1) { // -1 to skip back button
            val tv = tabRow.getChildAt(i) as? TextView ?: continue
            tv.setBackgroundColor(
                if (i == selected) if (t.isDark) Color.parseColor("#1C2B3A")
                else Color.parseColor("#D0D3D8")
                else Color.TRANSPARENT
            )
        }
    }

    private fun refreshGrid() {
        gridContainer.removeAllViews()
        val emojis = categories[selectedCat].second
        val scroll = ScrollView(ctx).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT)
        }
        val grid = GridLayout(ctx).apply {
            columnCount = 8
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT)
            setPadding(dp(4), dp(4), dp(4), dp(4))
        }
        emojis.forEach { emoji ->
            grid.addView(TextView(ctx).apply {
                text      = emoji
                textSize  = 24f
                gravity   = Gravity.CENTER
                val size  = dp(44)
                layoutParams = GridLayout.LayoutParams().apply {
                    width  = size
                    height = size
                }
                setOnClickListener {
                    performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
                    onEmoji(emoji)
                }
            })
        }
        scroll.addView(grid)
        gridContainer.addView(scroll)
    }

    private fun dp(v: Int) = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP, v.toFloat(), ctx.resources.displayMetrics).toInt()
}
