import 'package:flutter/material.dart';

/// Exact Samsung One UI keyboard colors from the reference image.
class KbTheme {
  final Color bg;           // keyboard background
  final Color letterKey;    // white letter key
  final Color specialKey;   // gray special key (shift/backspace/!#1/enter)
  final Color keyText;      // key label color
  final Color shadowColor;  // bottom shadow on keys
  final Color toolbarBg;    // top toolbar background
  final Color toolbarIcon;  // toolbar icon tint
  final Color divider;      // thin dividers
  final Color spaceText;    // "English (US)" label on space
  final Color enterBg;      // enter/Next key background
  final Color enterText;    // enter/Next key text

  const KbTheme._({
    required this.bg,
    required this.letterKey,
    required this.specialKey,
    required this.keyText,
    required this.shadowColor,
    required this.toolbarBg,
    required this.toolbarIcon,
    required this.divider,
    required this.spaceText,
    required this.enterBg,
    required this.enterText,
  });

  // Light theme — matches the reference image exactly
  static const light = KbTheme._(
    bg:          Color(0xFFD1D5DB), // gray keyboard bg
    letterKey:   Color(0xFFFFFFFF), // pure white keys
    specialKey:  Color(0xFFADB5BD), // medium gray for shift/backspace/!#1
    keyText:     Color(0xFF1A1A1A), // near-black text
    shadowColor: Color(0xFF9AA0A6), // bottom edge shadow
    toolbarBg:   Color(0xFFD1D5DB),
    toolbarIcon: Color(0xFF6B7280),
    divider:     Color(0xFFB0B5BB),
    spaceText:   Color(0xFF6B7280),
    enterBg:     Color(0xFF007AFF), // Samsung blue Next/Enter
    enterText:   Color(0xFFFFFFFF),
  );

  // Dark theme
  static const dark = KbTheme._(
    bg:          Color(0xFF1C1F24),
    letterKey:   Color(0xFF3C3F45),
    specialKey:  Color(0xFF23262B),
    keyText:     Color(0xFFFFFFFF),
    shadowColor: Color(0xFF111316),
    toolbarBg:   Color(0xFF1C1F24),
    toolbarIcon: Color(0xFF8A8A8A),
    divider:     Color(0xFF3A3D42),
    spaceText:   Color(0xFF8A8A8A),
    enterBg:     Color(0xFF007AFF),
    enterText:   Color(0xFFFFFFFF),
  );

  static KbTheme of(BuildContext ctx) =>
      MediaQuery.of(ctx).platformBrightness == Brightness.dark ? dark : light;
}
