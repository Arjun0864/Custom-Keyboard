package com.example.flutterboard

class KeyboardState {
    var shift   : Shift  = Shift.OFF
    var layout  : Layout = Layout.QWERTY
    var typing  : Boolean = false

    enum class Shift  { OFF, ONCE, CAPS }
    enum class Layout { QWERTY, NUMBERS, SYMBOLS }

    fun cycleShift() {
        shift = when (shift) {
            Shift.OFF  -> Shift.ONCE
            Shift.ONCE -> Shift.CAPS
            Shift.CAPS -> Shift.OFF
        }
    }

    fun afterChar() {
        if (shift == Shift.ONCE) shift = Shift.OFF
    }

    fun applyShift(ch: String): String =
        if (shift != Shift.OFF && ch.length == 1 && ch[0].isLetter())
            ch.uppercase() else ch
}
