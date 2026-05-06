package com.example.flutterboard

import android.content.Context
import android.content.res.Configuration
import android.graphics.Color

data class KeyboardTheme(
    val bg          : Int,
    val letterKey   : Int,
    val specialKey  : Int,
    val numKey      : Int,
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
    // From settings
    val radius      : Float,
    val fontSize    : Float,
    val keyOpacity  : Float,
    val hasShadow   : Boolean,
) {
    companion object {

        fun resolve(ctx: Context): KeyboardTheme {
            val dark   = KeyboardPrefs.isDark(ctx)
            val accent = KeyboardPrefs.accentColor(ctx)
            val r      = KeyboardPrefs.keyBorderRadius(ctx)
            val fs     = KeyboardPrefs.fontSize(ctx)
            val op     = KeyboardPrefs.keyOpacity(ctx)
            val shadow = KeyboardPrefs.keyShadow(ctx)

            return if (dark) dark(ctx, accent, r, fs, op, shadow)
            else light(ctx, accent, r, fs, op, shadow)
        }

        // ── Light ──────────────────────────────────────────────────────────────
        // Exact match to screenshot: bg #E3E5E8, white keys, gray special
        private fun light(
            ctx: Context, accent: Int, r: Float, fs: Float, op: Float, sh: Boolean
        ) = KeyboardTheme(
            bg          = Color.parseColor("#E3E5E8"),
            letterKey   = Color.WHITE,
            specialKey  = Color.parseColor("#C5C8CE"),
            numKey      = Color.WHITE,
            keyText     = Color.parseColor("#1A1A1A"),
            shadow      = Color.parseColor("#A8ADB5"),
            enterBg     = accent,
            enterText   = Color.WHITE,
            spaceText   = Color.parseColor("#6B7280"),
            toolbarBg   = Color.parseColor("#E3E5E8"),
            toolbarIcon = Color.parseColor("#6B7280"),
            divider     = Color.parseColor("#C5C8CE"),
            suggBg      = Color.parseColor("#E3E5E8"),
            suggCenter  = Color.parseColor("#1A1A1A"),
            suggSide    = Color.parseColor("#6B7280"),
            suggDivider = Color.parseColor("#C5C8CE"),
            shiftOn     = accent,
            isDark      = false,
            radius      = r,
            fontSize    = fs,
            keyOpacity  = op,
            hasShadow   = sh,
        )

        // ── Dark ───────────────────────────────────────────────────────────────
        private fun dark(
            ctx: Context, accent: Int, r: Float, fs: Float, op: Float, sh: Boolean
        ) = KeyboardTheme(
            bg          = Color.parseColor("#0D1117"),
            letterKey   = Color.parseColor("#1C2B3A"),
            specialKey  = Color.parseColor("#0D1117"),
            numKey      = Color.parseColor("#1C2B3A"),
            keyText     = Color.WHITE,
            shadow      = Color.parseColor("#050A0F"),
            enterBg     = accent,
            enterText   = Color.WHITE,
            spaceText   = Color.parseColor("#8A9BB0"),
            toolbarBg   = Color.parseColor("#0D1117"),
            toolbarIcon = Color.parseColor("#8A9BB0"),
            divider     = Color.parseColor("#1C2B3A"),
            suggBg      = Color.parseColor("#0D1117"),
            suggCenter  = Color.WHITE,
            suggSide    = Color.parseColor("#8A9BB0"),
            suggDivider = Color.parseColor("#1C2B3A"),
            shiftOn     = accent,
            isDark      = true,
            radius      = r,
            fontSize    = fs,
            keyOpacity  = op,
            hasShadow   = sh,
        )
    }
}
