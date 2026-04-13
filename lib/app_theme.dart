import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---- Theme Mode Provider ----
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('theme_mode') ?? 0;
    state = ThemeMode.values[modeIndex];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }
}

// ---- Keyboard Theme ----
enum KeyboardThemeType { material, glass, minimal, gradient, custom }

class KeyboardTheme {
  final String name;
  final KeyboardThemeType type;
  final Color backgroundColor;
  final Color keyColor;
  final Color keyPressedColor;
  final Color keyTextColor;
  final Color specialKeyColor;
  final Color suggestionBarColor;
  final Color suggestionTextColor;
  final double keyBorderRadius;
  final double? keyElevation;
  final bool hasBlur;
  final Gradient? backgroundGradient;
  final double keyOpacity;
  final Color? borderColor;

  const KeyboardTheme({
    required this.name,
    required this.type,
    required this.backgroundColor,
    required this.keyColor,
    required this.keyPressedColor,
    required this.keyTextColor,
    required this.specialKeyColor,
    required this.suggestionBarColor,
    required this.suggestionTextColor,
    this.keyBorderRadius = 8.0,
    this.keyElevation,
    this.hasBlur = false,
    this.backgroundGradient,
    this.keyOpacity = 1.0,
    this.borderColor,
  });

  KeyboardTheme copyWith({
    String? name,
    Color? backgroundColor,
    Color? keyColor,
    Color? keyPressedColor,
    Color? keyTextColor,
    Color? specialKeyColor,
    Color? suggestionBarColor,
    Color? suggestionTextColor,
    double? keyBorderRadius,
    double? keyElevation,
    bool? hasBlur,
    Gradient? backgroundGradient,
    double? keyOpacity,
    Color? borderColor,
  }) {
    return KeyboardTheme(
      name: name ?? this.name,
      type: type,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      keyColor: keyColor ?? this.keyColor,
      keyPressedColor: keyPressedColor ?? this.keyPressedColor,
      keyTextColor: keyTextColor ?? this.keyTextColor,
      specialKeyColor: specialKeyColor ?? this.specialKeyColor,
      suggestionBarColor: suggestionBarColor ?? this.suggestionBarColor,
      suggestionTextColor: suggestionTextColor ?? this.suggestionTextColor,
      keyBorderRadius: keyBorderRadius ?? this.keyBorderRadius,
      keyElevation: keyElevation ?? this.keyElevation,
      hasBlur: hasBlur ?? this.hasBlur,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      keyOpacity: keyOpacity ?? this.keyOpacity,
      borderColor: borderColor ?? this.borderColor,
    );
  }
}

class KeyboardThemes {
  static KeyboardTheme get materialLight => const KeyboardTheme(
    name: 'Material Light',
    type: KeyboardThemeType.material,
    backgroundColor: Color(0xFFD2D5DA),
    keyColor: Color(0xFFFFFFFF),
    keyPressedColor: Color(0xFFB8BCC4),
    keyTextColor: Color(0xFF1A1A2E),
    specialKeyColor: Color(0xFFADB5BD),
    suggestionBarColor: Color(0xFFF8F9FA),
    suggestionTextColor: Color(0xFF1A1A2E),
    keyBorderRadius: 8.0,
    keyElevation: 1.0,
  );

  static KeyboardTheme get materialDark => const KeyboardTheme(
    name: 'Material Dark',
    type: KeyboardThemeType.material,
    backgroundColor: Color(0xFF1E1E2E),
    keyColor: Color(0xFF2D2D44),
    keyPressedColor: Color(0xFF3D3D56),
    keyTextColor: Color(0xFFE0E0F0),
    specialKeyColor: Color(0xFF252538),
    suggestionBarColor: Color(0xFF16161E),
    suggestionTextColor: Color(0xFFE0E0F0),
    keyBorderRadius: 8.0,
    keyElevation: 2.0,
  );

  // Samsung-inspired Light Theme
  static KeyboardTheme get samsungLight => const KeyboardTheme(
    name: 'Samsung Light',
    type: KeyboardThemeType.material,
    backgroundColor: Color(0xFFF5F6F8),
    keyColor: Color(0xFFFFFFFF),
    keyPressedColor: Color(0xFFE8EAED),
    keyTextColor: Color(0xFF202124),
    specialKeyColor: Color(0xFFE0EBF1),
    suggestionBarColor: Color(0xFFFAFAFA),
    suggestionTextColor: Color(0xFF202124),
    keyBorderRadius: 10.0,
    keyElevation: 1.5,
    borderColor: Color(0xFFD3D3D6),
  );

  // Samsung-inspired Dark Theme (One UI)
  static KeyboardTheme get samsungDark => const KeyboardTheme(
    name: 'Samsung Dark',
    type: KeyboardThemeType.material,
    backgroundColor: Color(0xFF0F0F0F),
    keyColor: Color(0xFF1A1A1D),
    keyPressedColor: Color(0xFF2A2A2D),
    keyTextColor: Color(0xFFF0F0F2),
    specialKeyColor: Color(0xFF141417),
    suggestionBarColor: Color(0xFF0D0D0F),
    suggestionTextColor: Color(0xFFF0F0F2),
    keyBorderRadius: 10.0,
    keyElevation: 1.0,
    borderColor: Color(0xFF2A2A2D),
  );

  // Gboard Style Light
  static KeyboardTheme get gboardLight => const KeyboardTheme(
    name: 'Gboard Light',
    type: KeyboardThemeType.material,
    backgroundColor: Color(0xFFF1F3F4),
    keyColor: Color(0xFFFFFFFF),
    keyPressedColor: Color(0xFFEAEBEC),
    keyTextColor: Color(0xFF202124),
    specialKeyColor: Color(0xFFF5F6F7),
    suggestionBarColor: Color(0xFFFCFDFD),
    suggestionTextColor: Color(0xFF202124),
    keyBorderRadius: 8.0,
    keyElevation: 0.5,
  );

  // Gboard Style Dark
  static KeyboardTheme get gboardDark => const KeyboardTheme(
    name: 'Gboard Dark',
    type: KeyboardThemeType.material,
    backgroundColor: Color(0xFF121212),
    keyColor: Color(0xFF212121),
    keyPressedColor: Color(0xFF373737),
    keyTextColor: Color(0xFFFAFAFA),
    specialKeyColor: Color(0xFF1D1D1D),
    suggestionBarColor: Color(0xFF0F0F0F),
    suggestionTextColor: Color(0xFFFAFAFA),
    keyBorderRadius: 8.0,
    keyElevation: 1.0,
  );

  static KeyboardTheme get glassLight => KeyboardTheme(
    name: 'Glass Light',
    type: KeyboardThemeType.glass,
    backgroundColor: const Color(0xAAF0F4FF),
    keyColor: const Color(0x80FFFFFF),
    keyPressedColor: const Color(0x60FFFFFF),
    keyTextColor: const Color(0xFF1A1A2E),
    specialKeyColor: const Color(0x60CCDDFF),
    suggestionBarColor: const Color(0x80F8F9FA),
    suggestionTextColor: const Color(0xFF1A1A2E),
    keyBorderRadius: 12.0,
    hasBlur: true,
    keyOpacity: 0.8,
    borderColor: const Color(0x40FFFFFF),
  );

  static KeyboardTheme get glassDark => KeyboardTheme(
    name: 'Glass Dark',
    type: KeyboardThemeType.glass,
    backgroundColor: const Color(0xAA0D0D1A),
    keyColor: const Color(0x40FFFFFF),
    keyPressedColor: const Color(0x60FFFFFF),
    keyTextColor: const Color(0xFFE0E8FF),
    specialKeyColor: const Color(0x30AABBFF),
    suggestionBarColor: const Color(0x80080810),
    suggestionTextColor: const Color(0xFFE0E8FF),
    keyBorderRadius: 12.0,
    hasBlur: true,
    keyOpacity: 0.6,
    borderColor: const Color(0x30FFFFFF),
  );

  static KeyboardTheme get minimal => const KeyboardTheme(
    name: 'Minimal',
    type: KeyboardThemeType.minimal,
    backgroundColor: Color(0xFFF5F5F5),
    keyColor: Color(0xFFF5F5F5),
    keyPressedColor: Color(0xFFE0E0E0),
    keyTextColor: Color(0xFF333333),
    specialKeyColor: Color(0xFFEEEEEE),
    suggestionBarColor: Color(0xFFFFFFFF),
    suggestionTextColor: Color(0xFF333333),
    keyBorderRadius: 0.0,
    keyElevation: 0.0,
  );

  static KeyboardTheme get gradient => KeyboardTheme(
    name: 'Cosmic Gradient',
    type: KeyboardThemeType.gradient,
    backgroundColor: const Color(0xFF1A0533),
    keyColor: const Color(0xFF2D1060),
    keyPressedColor: const Color(0xFF4A1A9E),
    keyTextColor: const Color(0xFFEEDDFF),
    specialKeyColor: const Color(0xFF1E0B42),
    suggestionBarColor: const Color(0xFF120224),
    suggestionTextColor: const Color(0xFFEEDDFF),
    keyBorderRadius: 10.0,
    backgroundGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A0533), Color(0xFF0D1060), Color(0xFF1A0533)],
    ),
  );

  static KeyboardTheme get amoled => const KeyboardTheme(
    name: 'AMOLED',
    type: KeyboardThemeType.material,
    backgroundColor: Color(0xFF000000),
    keyColor: Color(0xFF111111),
    keyPressedColor: Color(0xFF222222),
    keyTextColor: Color(0xFFFFFFFF),
    specialKeyColor: Color(0xFF0A0A0A),
    suggestionBarColor: Color(0xFF000000),
    suggestionTextColor: Color(0xFFFFFFFF),
    keyBorderRadius: 8.0,
  );

  // Material You Light
  static KeyboardTheme get materialYouLight => const KeyboardTheme(
    name: 'Material You Light',
    type: KeyboardThemeType.material,
    backgroundColor: Color(0xFFFEF7EE),
    keyColor: Color(0xFFFFFBFE),
    keyPressedColor: Color(0xFFF3EFF5),
    keyTextColor: Color(0xFF1C1B1F),
    specialKeyColor: Color(0xFFFAF0F6),
    suggestionBarColor: Color(0xFFFFFBFE),
    suggestionTextColor: Color(0xFF1C1B1F),
    keyBorderRadius: 10.0,
    keyElevation: 1.0,
  );

  // Material You Dark
  static KeyboardTheme get materialYouDark => const KeyboardTheme(
    name: 'Material You Dark',
    type: KeyboardThemeType.material,
    backgroundColor: Color(0xFF1C1B1F),
    keyColor: Color(0xFF2C2C31),
    keyPressedColor: Color(0xFF3C3C42),
    keyTextColor: Color(0xFFEAE1FF),
    specialKeyColor: Color(0xFF242429),
    suggestionBarColor: Color(0xFF16151A),
    suggestionTextColor: Color(0xFFEAE1FF),
    keyBorderRadius: 10.0,
    keyElevation: 1.5,
  );

  static List<KeyboardTheme> get allThemes => [
    materialLight,
    materialDark,
    samsungLight,
    samsungDark,
    gboardLight,
    gboardDark,
    glassLight,
    glassDark,
    minimal,
    gradient,
    amoled,
    materialYouLight,
    materialYouDark,
  ];
}

// ---- Active Keyboard Theme Provider ----
final keyboardThemeProvider = StateNotifierProvider<KeyboardThemeNotifier, KeyboardTheme>((ref) {
  return KeyboardThemeNotifier();
});

class KeyboardThemeNotifier extends StateNotifier<KeyboardTheme> {
  KeyboardThemeNotifier() : super(KeyboardThemes.materialLight) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('keyboard_theme') ?? 0;
    if (themeIndex < KeyboardThemes.allThemes.length) {
      state = KeyboardThemes.allThemes[themeIndex];
    }
  }

  Future<void> setTheme(KeyboardTheme theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    final index = KeyboardThemes.allThemes.indexOf(theme);
    await prefs.setInt('keyboard_theme', index >= 0 ? index : 0);
  }

  void updateKeyColor(Color color) {
    state = state.copyWith(keyColor: color);
  }

  void updateBackgroundColor(Color color) {
    state = state.copyWith(backgroundColor: color);
  }

  void updateKeyTextColor(Color color) {
    state = state.copyWith(keyTextColor: color);
  }

  void updateBorderRadius(double radius) {
    state = state.copyWith(keyBorderRadius: radius);
  }
}

// ---- Material App Theme ----
class AppTheme {
  static final KeyboardTheme materialLightTheme = KeyboardThemes.materialLight;
  static final KeyboardTheme materialDarkTheme = KeyboardThemes.materialDark;

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: Brightness.light,
    ),
    fontFamily: 'NotoSans',
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: Brightness.dark,
    ),
    fontFamily: 'NotoSans',
  );

  static KeyboardTheme of(BuildContext context) {
    // Return theme from context if available
    return KeyboardThemes.materialLight;
  }
}

