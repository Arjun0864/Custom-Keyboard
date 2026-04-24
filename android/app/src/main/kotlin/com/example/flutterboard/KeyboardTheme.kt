package com.example.flutterboard

import android.content.res.Configuration
import android.graphics.Color

data class KeyboardTheme(
    val bg          : Int,
    val letterKey   : Int,
    val specialKey  : Int,
    val numKey      : Int,   // number row key bg (same as letterKey in light, darker in dark)
    val keyText     : Int,
    val shadow      : Int,
    val enterBg     : Int,
    val enterText   : Int,
    val spaceText   : Int,
    val toolbarBg   : Int,
    val toolbarIcon : Int,
    val divider     : Int,
    val suggBg      : Int,
    val suggCenter  : Int,
    val suggSide    : Int,
    val suggDivider : Int,
    val shiftOn     : Int,
    val isDark      : Boolean,
) {
    companion object {

        // ── Light — matches right reference image exactly ──────────────────────
        val LIGHT = KeyboardTheme(
            bg          = Color.parseColor("#D4D7DC"),  // Samsung light gray bg
            letterKey   = Color.parseColor("#FFFFFF"),  // pure white letter keys
            specialKey  = Color.parseColor("#B0B6BE"),  // gray special keys
            numKey      = Color.parseColor("#FFFFFF"),  // number row same as letter
            keyText     = Color.parseColor("#1A1A1A"),
            shadow      = Color.parseColor("#9AA0A6"),
            enterBg     = Color.parseColor("#007AFF"),  // Samsung blue
            enterText   = Color.WHITE,
            spaceText   = Color.parseColor("#6B7280"),
            toolbarBg   = Color.parseColor("#D4D7DC"),
            toolbarIcon = Color.parseColor("#6B7280"),
            divider     = Color.parseColor("#B8BCC2"),
            suggBg      = Color.parseColor("#D4D7DC"),
            suggCenter  = Color.parseColor("#1A1A1A"),
            suggSide    = Color.parseColor("#6B7280"),
            suggDivider = Color.parseColor("#B8BCC2"),
            shiftOn     = Color.parseColor("#007AFF"),
            isDark      = false,
        )

        // ── Dark — matches left reference image exactly ────────────────────────
        // Background: very dark navy, keys: dark teal/slate
        val DARK = KeyboardTheme(
            bg          = Color.parseColor("#0E1621"),  // very dark navy bg
            letterKey   = Color.parseColor("#1B2B3A"),  // dark teal letter keys
            specialKey  = Color.parseColor("#0E1621"),  // same as bg for special keys
            numKey      = Color.parseColor("#1B2B3A"),  // number row same as letter
            keyText     = Color.parseColor("#FFFFFF"),
            shadow      = Color.parseColor("#060C12"),
            enterBg     = Color.parseColor("#007AFF"),
            enterText   = Color.WHITE,
            spaceText   = Color.parseColor("#8A9BB0"),
            toolbarBg   = Color.parseColor("#0E1621"),
            toolbarIcon = Color.parseColor("#8A9BB0"),
            divider     = Color.parseColor("#1E2D3D"),
            suggBg      = Color.parseColor("#0E1621"),
            suggCenter  = Color.WHITE,
            suggSide    = Color.parseColor("#8A9BB0"),
            suggDivider = Color.parseColor("#1E2D3D"),
            shiftOn     = Color.parseColor("#007AFF"),
            isDark      = true,
        )

        fun resolve(ctx: android.content.Context): KeyboardTheme {
            val isDark = (ctx.resources.configuration.uiMode and
                    Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
            return if (isDark) DARK else LIGHT
        }
    }
}
