package com.example.flutterboard

import android.content.Context
import android.content.res.Configuration
import android.os.Build
import android.util.TypedValue
import android.view.WindowInsets

/**
 * All keyboard dimensions computed once from screen metrics.
 * Uses Samsung's exact proportional system.
 */
data class Dims(
    val toolbarH  : Int,   // 40 dp
    val numRowH   : Int,   // 32 dp  — slim number-hint row
    val keyH      : Int,   // ~46 dp — letter rows 1-3
    val bottomH   : Int,   // ~52 dp — bottom function row
    val keyGap    : Int,   // 6 dp
    val rowGap    : Int,   // 8 dp
    val edgePad   : Int,   // 8 dp each side
    val topPad    : Int,   // 6 dp above first row
    val botPad    : Int,   // 8 dp + navBar
    val radius    : Float, // 8 dp
    val navBarPx  : Int,
    val screenW   : Int,
) {
    companion object {
        fun compute(ctx: Context): Dims {
            val dm      = ctx.resources.displayMetrics
            val screenH = dm.heightPixels
            val screenW = dm.widthPixels
            val isLand  = ctx.resources.configuration.orientation ==
                    Configuration.ORIENTATION_LANDSCAPE

            fun dp(v: Int) = TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, v.toFloat(), dm).toInt()

            val navBar = measureNavBar(ctx)

            // Fixed structural heights (dp)
            val toolbarH = dp(40)
            val divider  = dp(1)
            val numRowH  = dp(32)
            val topPad   = dp(6)
            val keyGap   = dp(6)
            val rowGap   = dp(8)
            val edgePad  = dp(8)
            val botPad   = dp(8) + navBar

            // Target: 37% portrait, 50% landscape
            val targetH = (screenH * if (isLand) 0.50f else 0.37f).toInt()

            // Overhead = toolbar + divider + numRow + topPad + 3*rowGap + botPad
            val overhead = toolbarH + divider + numRowH + topPad +
                    (3 * rowGap) + botPad

            // 4 rows: 3 letter rows + 1 bottom row (bottomH = keyH + dp(6))
            // targetH = overhead + 3*keyH + (keyH + dp(6))
            //         = overhead + 4*keyH + dp(6)
            // keyH = (targetH - overhead - dp(6)) / 4
            val keyH    = ((targetH - overhead - dp(6)) / 4)
                .coerceIn(dp(42), dp(54))
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

        private fun measureNavBar(ctx: Context): Int {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                // Try to get from the service window — may be null at init time
            }
            val id = ctx.resources.getIdentifier(
                "navigation_bar_height", "dimen", "android")
            return if (id > 0) ctx.resources.getDimensionPixelSize(id) else 0
        }

        fun measureNavBarFromWindow(ctx: Context, window: android.view.Window?): Int {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && window != null) {
                val h = window.decorView.rootWindowInsets
                    ?.getInsets(WindowInsets.Type.navigationBars())?.bottom ?: 0
                if (h > 0) return h
            }
            val id = ctx.resources.getIdentifier(
                "navigation_bar_height", "dimen", "android")
            return if (id > 0) ctx.resources.getDimensionPixelSize(id) else 0
        }
    }
}
