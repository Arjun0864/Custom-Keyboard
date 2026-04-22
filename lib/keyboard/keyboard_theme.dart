import 'package:flutter/material.dart';

/// Samsung One UI exact color tokens
class KbColors {
  final Color keyboardBg;
  final Color letterKeyBg;
  final Color specialKeyBg;
  final Color keyText;
  final Color suggestionBg;
  final Color suggestionText;
  final Color suggestionSide;
  final Color toolbarBg;
  final Color toolbarIcon;
  final Color divider;
  final Color accentBlue;
  final Color shadow;

  const KbColors._({
    required this.keyboardBg,
    required this.letterKeyBg,
    required this.specialKeyBg,
    required this.keyText,
    required this.suggestionBg,
    required this.suggestionText,
    required this.suggestionSide,
    required this.toolbarBg,
    required this.toolbarIcon,
    required this.divider,
    required this.accentBlue,
    required this.shadow,
  });

  // ── Light theme ────────────────────────────────────────────────────────────
  static const light = KbColors._(
    keyboardBg:     Color(0xFFE3E6EA),
    letterKeyBg:    Color(0xFFFFFFFF),
    specialKeyBg:   Color(0xFFCFD3D8),
    keyText:        Color(0xFF1A1A1A),
    suggestionBg:   Color(0xFFE3E6EA),
    suggestionText: Color(0xFF1A1A1A),
    suggestionSide: Color(0xFF666666),
    toolbarBg:      Color(0xFFE3E6EA),
    toolbarIcon:    Color(0xFF8A8A8A),
    divider:        Color(0xFFB0B5BB),
    accentBlue:     Color(0xFF007AFF),
    shadow:         Color(0x33000000),
  );

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static const dark = KbColors._(
    keyboardBg:     Color(0xFF1C1F24),
    letterKeyBg:    Color(0xFF3C3F45),
    specialKeyBg:   Color(0xFF23262B),
    keyText:        Color(0xFFFFFFFF),
    suggestionBg:   Color(0xFF1C1F24),
    suggestionText: Color(0xFFFFFFFF),
    suggestionSide: Color(0xFFAAAAAA),
    toolbarBg:      Color(0xFF1C1F24),
    toolbarIcon:    Color(0xFF8A8A8A),
    divider:        Color(0xFF3A3D42),
    accentBlue:     Color(0xFF007AFF),
    shadow:         Color(0x55000000),
  );

  /// Auto-detect from system brightness
  static KbColors of(BuildContext context) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark ? dark : light;
  }
}
