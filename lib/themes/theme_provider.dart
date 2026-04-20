import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Color mode for the keyboard
enum ColorMode {
  light,
  dark,
  auto, // System preference
}

/// Key shape styles
enum KeyShape {
  rectangle,
  rounded,
  bubble,
  minimal,
}

/// One-handed mode options
enum OneHandedMode {
  off,
  left,
  right,
}

/// Sound theme options
enum SoundTheme {
  off,
  click,
  typewriter,
  soft,
  pop,
}

/// Key animation options
enum KeyAnimation {
  none,
  scale,
  ripple,
  bounce,
}

/// Emoji style options
enum EmojiStyle {
  system,
  ios,
  flat,
  outlined,
}

/// Background style options
enum BackgroundStyle {
  solid,
  gradient,
  blur,
  image,
}

/// Represents a Samsung color preset
class ColorPreset {
  final String name;
  final Color color;

  ColorPreset({required this.name, required this.color});
}

/// Custom saved theme
class CustomTheme {
  final String id;
  final String name;
  final String themeJson;
  final DateTime createdAt;

  CustomTheme({
    required this.id,
    required this.name,
    required this.themeJson,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'themeJson': themeJson,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomTheme.fromMap(Map<String, dynamic> map) {
    return CustomTheme(
      id: map['id'],
      name: map['name'],
      themeJson: map['themeJson'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

/// Comprehensive GoodLock-style theme provider
class ThemeProvider extends ChangeNotifier {
  // SharedPreferences instance
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Color mode
  ColorMode _colorMode = ColorMode.light;

  // Accent color (can be preset or custom hex)
  Color _accentColor = Colors.blue;
  bool _isCustomColor = false;
  String _customColorHex = '#2196F3';

  // Key appearance
  double _keyOpacity = 1.0;
  double _keyBorderRadius = 8.0;
  double _keyGapSpacing = 4.0;
  KeyShape _keyShape = KeyShape.rounded;

  // Typography
  String _fontFamily = 'Default';
  double _fontSize = 16.0;
  FontWeight _fontWeight = FontWeight.w500;

  // Keyboard dimensions
  double _keyboardHeight = 250.0; // Normal preset
  bool _floatingMode = false;
  double _floatingSize = 0.8; // 80% of screen width

  // Layout
  bool _rowStagger = false;
  OneHandedMode _oneHandedMode = OneHandedMode.off;
  double _oneHandedShiftPercent = 30.0;

  // Background
  BackgroundStyle _backgroundStyle = BackgroundStyle.solid;
  Color _backgroundColor = const Color(0xFFE8E8E8);
  String _backgroundImagePath = '';

  // Effects
  bool _keyShadow = true;
  double _shadowIntensity = 0.5;
  SoundTheme _soundTheme = SoundTheme.click;
  int _vibrationIntensity = 2; // 0-3
  KeyAnimation _keyAnimation = KeyAnimation.scale;
  EmojiStyle _emojiStyle = EmojiStyle.system;

  // Custom themes
  List<CustomTheme> _customThemes = [];

  // Getters
  bool get isInitialized => _isInitialized;
  ColorMode get colorMode => _colorMode;
  Color get accentColor => _accentColor;
  bool get isCustomColor => _isCustomColor;
  String get customColorHex => _customColorHex;
  double get keyOpacity => _keyOpacity;
  double get keyBorderRadius => _keyBorderRadius;
  double get keyGapSpacing => _keyGapSpacing;
  KeyShape get keyShape => _keyShape;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  FontWeight get fontWeight => _fontWeight;
  double get keyboardHeight => _keyboardHeight;
  bool get floatingMode => _floatingMode;
  double get floatingSize => _floatingSize;
  bool get rowStagger => _rowStagger;
  OneHandedMode get oneHandedMode => _oneHandedMode;
  double get oneHandedShiftPercent => _oneHandedShiftPercent;
  BackgroundStyle get backgroundStyle => _backgroundStyle;
  Color get backgroundColor => _backgroundColor;
  String get backgroundImagePath => _backgroundImagePath;
  bool get keyShadow => _keyShadow;
  double get shadowIntensity => _shadowIntensity;
  SoundTheme get soundTheme => _soundTheme;
  int get vibrationIntensity => _vibrationIntensity;
  KeyAnimation get keyAnimation => _keyAnimation;
  EmojiStyle get emojiStyle => _emojiStyle;
  List<CustomTheme> get customThemes => _customThemes;

  // Samsung color presets (12 colors)
  static final List<ColorPreset> samsungColors = [
    ColorPreset(name: 'Blue', color: const Color(0xFF2196F3)),
    ColorPreset(name: 'Purple', color: const Color(0xFF9C27B0)),
    ColorPreset(name: 'Pink', color: const Color(0xFFE91E63)),
    ColorPreset(name: 'Red', color: const Color(0xFFF44336)),
    ColorPreset(name: 'Orange', color: const Color(0xFFFF9800)),
    ColorPreset(name: 'Yellow', color: const Color(0xFFFFC107)),
    ColorPreset(name: 'Green', color: const Color(0xFF4CAF50)),
    ColorPreset(name: 'Teal', color: const Color(0xFF009688)),
    ColorPreset(name: 'Cyan', color: const Color(0xFF00BCD4)),
    ColorPreset(name: 'Indigo', color: const Color(0xFF3F51B5)),
    ColorPreset(name: 'Deep Purple', color: const Color(0xFF673AB7)),
    ColorPreset(name: 'Gray', color: const Color(0xFF9E9E9E)),
  ];

  /// Initialize the theme provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _loadFromPreferences();
    _loadCustomThemes();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load all settings from SharedPreferences
  void _loadFromPreferences() {
    _colorMode = ColorMode.values[_prefs.getInt('colorMode') ?? 0];
    _isCustomColor = _prefs.getBool('isCustomColor') ?? false;
    _customColorHex = _prefs.getString('customColorHex') ?? '#2196F3';
    _accentColor = Color(int.parse(_customColorHex.replaceFirst('#', '0xFF')));

    _keyOpacity = _prefs.getDouble('keyOpacity') ?? 1.0;
    _keyBorderRadius = _prefs.getDouble('keyBorderRadius') ?? 8.0;
    _keyGapSpacing = _prefs.getDouble('keyGapSpacing') ?? 4.0;
    _keyShape = KeyShape.values[_prefs.getInt('keyShape') ?? 1];

    _fontFamily = _prefs.getString('fontFamily') ?? 'Default';
    _fontSize = _prefs.getDouble('fontSize') ?? 16.0;
    final fontWeightValue = _prefs.getInt('fontWeight') ?? 500;
    _fontWeight = FontWeight.values[_fontWeightToIndex(fontWeightValue)];

    _keyboardHeight = _prefs.getDouble('keyboardHeight') ?? 250.0;
    _floatingMode = _prefs.getBool('floatingMode') ?? false;
    _floatingSize = _prefs.getDouble('floatingSize') ?? 0.8;

    _rowStagger = _prefs.getBool('rowStagger') ?? false;
    _oneHandedMode = OneHandedMode.values[_prefs.getInt('oneHandedMode') ?? 0];
    _oneHandedShiftPercent = _prefs.getDouble('oneHandedShiftPercent') ?? 30.0;

    _backgroundStyle = BackgroundStyle.values[_prefs.getInt('backgroundStyle') ?? 0];
    _backgroundColor = Color(int.parse(_prefs.getString('backgroundColor') ?? '0xFFE8E8E8'));
    _backgroundImagePath = _prefs.getString('backgroundImagePath') ?? '';

    _keyShadow = _prefs.getBool('keyShadow') ?? true;
    _shadowIntensity = _prefs.getDouble('shadowIntensity') ?? 0.5;
    _soundTheme = SoundTheme.values[_prefs.getInt('soundTheme') ?? 1];
    _vibrationIntensity = _prefs.getInt('vibrationIntensity') ?? 2;
    _keyAnimation = KeyAnimation.values[_prefs.getInt('keyAnimation') ?? 1];
    _emojiStyle = EmojiStyle.values[_prefs.getInt('emojiStyle') ?? 0];
  }

  /// Load custom themes from SharedPreferences
  Future<void> _loadCustomThemes() async {
    final themesJson = _prefs.getString('customThemes');
    if (themesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(themesJson);
        _customThemes = decoded.map((item) => CustomTheme.fromMap(item as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Error loading custom themes: $e');
      }
    }
  }

  /// Save custom themes to SharedPreferences
  Future<void> _saveCustomThemes() async {
    final themesJson = jsonEncode(_customThemes.map((t) => t.toMap()).toList());
    await _prefs.setString('customThemes', themesJson);
  }

  // Setters with persistence
  Future<void> setColorMode(ColorMode mode) async {
    if (_colorMode == mode) return;
    _colorMode = mode;
    await _prefs.setInt('colorMode', mode.index);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    _isCustomColor = false;
    await _prefs.setBool('isCustomColor', false);
    notifyListeners();
  }

  Future<void> setCustomColor(String hexColor) async {
    try {
      _accentColor = Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
      _customColorHex = hexColor;
      _isCustomColor = true;
      await _prefs.setBool('isCustomColor', true);
      await _prefs.setString('customColorHex', hexColor);
      notifyListeners();
    } catch (e) {
      debugPrint('Invalid hex color: $hexColor');
    }
  }

  Future<void> setKeyOpacity(double opacity) async {
    _keyOpacity = opacity.clamp(0.0, 1.0);
    await _prefs.setDouble('keyOpacity', _keyOpacity);
    notifyListeners();
  }

  Future<void> setKeyBorderRadius(double radius) async {
    _keyBorderRadius = radius.clamp(0.0, 20.0);
    await _prefs.setDouble('keyBorderRadius', _keyBorderRadius);
    notifyListeners();
  }

  Future<void> setKeyGapSpacing(double gap) async {
    _keyGapSpacing = gap.clamp(2.0, 8.0);
    await _prefs.setDouble('keyGapSpacing', _keyGapSpacing);
    notifyListeners();
  }

  Future<void> setKeyShape(KeyShape shape) async {
    if (_keyShape == shape) return;
    _keyShape = shape;
    await _prefs.setInt('keyShape', shape.index);
    notifyListeners();
  }

  Future<void> setFontFamily(String family) async {
    if (_fontFamily == family) return;
    _fontFamily = family;
    await _prefs.setString('fontFamily', family);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(12.0, 18.0);
    await _prefs.setDouble('fontSize', _fontSize);
    notifyListeners();
  }

  Future<void> setFontWeight(FontWeight weight) async {
    if (_fontWeight == weight) return;
    _fontWeight = weight;
    await _prefs.setInt('fontWeight', _fontWeightToValue(weight));
    notifyListeners();
  }

  Future<void> setKeyboardHeight(double height) async {
    _keyboardHeight = height;
    await _prefs.setDouble('keyboardHeight', height);
    notifyListeners();
  }

  Future<void> setFloatingMode(bool enabled) async {
    if (_floatingMode == enabled) return;
    _floatingMode = enabled;
    await _prefs.setBool('floatingMode', enabled);
    notifyListeners();
  }

  Future<void> setFloatingSize(double size) async {
    _floatingSize = size.clamp(0.5, 1.0);
    await _prefs.setDouble('floatingSize', _floatingSize);
    notifyListeners();
  }

  Future<void> setRowStagger(bool stagger) async {
    if (_rowStagger == stagger) return;
    _rowStagger = stagger;
    await _prefs.setBool('rowStagger', stagger);
    notifyListeners();
  }

  Future<void> setOneHandedMode(OneHandedMode mode) async {
    if (_oneHandedMode == mode) return;
    _oneHandedMode = mode;
    await _prefs.setInt('oneHandedMode', mode.index);
    notifyListeners();
  }

  Future<void> setOneHandedShift(double percent) async {
    _oneHandedShiftPercent = percent.clamp(10.0, 50.0);
    await _prefs.setDouble('oneHandedShiftPercent', _oneHandedShiftPercent);
    notifyListeners();
  }

  Future<void> setBackgroundStyle(BackgroundStyle style) async {
    if (_backgroundStyle == style) return;
    _backgroundStyle = style;
    await _prefs.setInt('backgroundStyle', style.index);
    notifyListeners();
  }

  Future<void> setBackgroundColor(Color color) async {
    _backgroundColor = color;
    await _prefs.setString('backgroundColor', '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}');
    notifyListeners();
  }

  Future<void> setBackgroundImagePath(String path) async {
    _backgroundImagePath = path;
    await _prefs.setString('backgroundImagePath', path);
    notifyListeners();
  }

  Future<void> setKeyShadow(bool enabled) async {
    if (_keyShadow == enabled) return;
    _keyShadow = enabled;
    await _prefs.setBool('keyShadow', enabled);
    notifyListeners();
  }

  Future<void> setShadowIntensity(double intensity) async {
    _shadowIntensity = intensity.clamp(0.0, 1.0);
    await _prefs.setDouble('shadowIntensity', _shadowIntensity);
    notifyListeners();
  }

  Future<void> setSoundTheme(SoundTheme theme) async {
    if (_soundTheme == theme) return;
    _soundTheme = theme;
    await _prefs.setInt('soundTheme', theme.index);
    notifyListeners();
  }

  Future<void> setVibrationIntensity(int intensity) async {
    _vibrationIntensity = intensity.clamp(0, 3);
    await _prefs.setInt('vibrationIntensity', _vibrationIntensity);
    notifyListeners();
  }

  Future<void> setKeyAnimation(KeyAnimation animation) async {
    if (_keyAnimation == animation) return;
    _keyAnimation = animation;
    await _prefs.setInt('keyAnimation', animation.index);
    notifyListeners();
  }

  Future<void> setEmojiStyle(EmojiStyle style) async {
    if (_emojiStyle == style) return;
    _emojiStyle = style;
    await _prefs.setInt('emojiStyle', style.index);
    notifyListeners();
  }

  /// Save current theme as custom preset
  Future<void> saveAsCustomTheme(String themeName) async {
    final themeJson = _captureCurrentThemeJson();
    final customTheme = CustomTheme(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: themeName,
      themeJson: themeJson,
      createdAt: DateTime.now(),
    );
    _customThemes.add(customTheme);
    await _saveCustomThemes();
    notifyListeners();
  }

  /// Load a custom theme
  Future<void> loadCustomTheme(CustomTheme theme) async {
    try {
      final themeMap = jsonDecode(theme.themeJson) as Map<String, dynamic>;
      _applyThemeFromMap(themeMap);
      await _saveAllToPreferences();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading custom theme: $e');
    }
  }

  /// Delete a custom theme
  Future<void> deleteCustomTheme(String themeId) async {
    _customThemes.removeWhere((theme) => theme.id == themeId);
    await _saveCustomThemes();
    notifyListeners();
  }

  /// Capture current theme settings as JSON
  String _captureCurrentThemeJson() {
    return jsonEncode({
      'colorMode': _colorMode.index,
      'accentColor': _accentColor.value.toRadixString(16),
      'isCustomColor': _isCustomColor,
      'customColorHex': _customColorHex,
      'keyOpacity': _keyOpacity,
      'keyBorderRadius': _keyBorderRadius,
      'keyGapSpacing': _keyGapSpacing,
      'keyShape': _keyShape.index,
      'fontFamily': _fontFamily,
      'fontSize': _fontSize,
      'fontWeight': _fontWeightToValue(_fontWeight),
      'keyboardHeight': _keyboardHeight,
      'floatingMode': _floatingMode,
      'floatingSize': _floatingSize,
      'rowStagger': _rowStagger,
      'oneHandedMode': _oneHandedMode.index,
      'oneHandedShiftPercent': _oneHandedShiftPercent,
      'backgroundStyle': _backgroundStyle.index,
      'backgroundColor': _backgroundColor.value.toRadixString(16),
      'backgroundImagePath': _backgroundImagePath,
      'keyShadow': _keyShadow,
      'shadowIntensity': _shadowIntensity,
      'soundTheme': _soundTheme.index,
      'vibrationIntensity': _vibrationIntensity,
      'keyAnimation': _keyAnimation.index,
      'emojiStyle': _emojiStyle.index,
    });
  }

  /// Apply theme from JSON map
  void _applyThemeFromMap(Map<String, dynamic> map) {
    _colorMode = ColorMode.values[map['colorMode'] ?? 0];
    _accentColor = Color(int.parse(map['accentColor'] ?? 'FF2196F3', radix: 16));
    _isCustomColor = map['isCustomColor'] ?? false;
    _customColorHex = map['customColorHex'] ?? '#2196F3';
    _keyOpacity = (map['keyOpacity'] ?? 1.0).toDouble();
    _keyBorderRadius = (map['keyBorderRadius'] ?? 8.0).toDouble();
    _keyGapSpacing = (map['keyGapSpacing'] ?? 4.0).toDouble();
    _keyShape = KeyShape.values[map['keyShape'] ?? 1];
    _fontFamily = map['fontFamily'] ?? 'Default';
    _fontSize = (map['fontSize'] ?? 16.0).toDouble();
    _fontWeight = _indexToFontWeight(_fontWeightToIndex(map['fontWeight'] ?? 500));
    _keyboardHeight = (map['keyboardHeight'] ?? 250.0).toDouble();
    _floatingMode = map['floatingMode'] ?? false;
    _floatingSize = (map['floatingSize'] ?? 0.8).toDouble();
    _rowStagger = map['rowStagger'] ?? false;
    _oneHandedMode = OneHandedMode.values[map['oneHandedMode'] ?? 0];
    _oneHandedShiftPercent = (map['oneHandedShiftPercent'] ?? 30.0).toDouble();
    _backgroundStyle = BackgroundStyle.values[map['backgroundStyle'] ?? 0];
    _backgroundColor = Color(int.parse(map['backgroundColor'] ?? 'FFE8E8E8', radix: 16));
    _backgroundImagePath = map['backgroundImagePath'] ?? '';
    _keyShadow = map['keyShadow'] ?? true;
    _shadowIntensity = (map['shadowIntensity'] ?? 0.5).toDouble();
    _soundTheme = SoundTheme.values[map['soundTheme'] ?? 1];
    _vibrationIntensity = map['vibrationIntensity'] ?? 2;
    _keyAnimation = KeyAnimation.values[map['keyAnimation'] ?? 1];
    _emojiStyle = EmojiStyle.values[map['emojiStyle'] ?? 0];
  }

  /// Save all settings to SharedPreferences
  Future<void> _saveAllToPreferences() async {
    await _prefs.setInt('colorMode', _colorMode.index);
    await _prefs.setBool('isCustomColor', _isCustomColor);
    await _prefs.setString('customColorHex', _customColorHex);
    await _prefs.setDouble('keyOpacity', _keyOpacity);
    await _prefs.setDouble('keyBorderRadius', _keyBorderRadius);
    await _prefs.setDouble('keyGapSpacing', _keyGapSpacing);
    await _prefs.setInt('keyShape', _keyShape.index);
    await _prefs.setString('fontFamily', _fontFamily);
    await _prefs.setDouble('fontSize', _fontSize);
    await _prefs.setInt('fontWeight', _fontWeightToValue(_fontWeight));
    await _prefs.setDouble('keyboardHeight', _keyboardHeight);
    await _prefs.setBool('floatingMode', _floatingMode);
    await _prefs.setDouble('floatingSize', _floatingSize);
    await _prefs.setBool('rowStagger', _rowStagger);
    await _prefs.setInt('oneHandedMode', _oneHandedMode.index);
    await _prefs.setDouble('oneHandedShiftPercent', _oneHandedShiftPercent);
    await _prefs.setInt('backgroundStyle', _backgroundStyle.index);
    await _prefs.setString('backgroundColor', '#${_backgroundColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}');
    await _prefs.setString('backgroundImagePath', _backgroundImagePath);
    await _prefs.setBool('keyShadow', _keyShadow);
    await _prefs.setDouble('shadowIntensity', _shadowIntensity);
    await _prefs.setInt('soundTheme', _soundTheme.index);
    await _prefs.setInt('vibrationIntensity', _vibrationIntensity);
    await _prefs.setInt('keyAnimation', _keyAnimation.index);
    await _prefs.setInt('emojiStyle', _emojiStyle.index);
  }

  /// Reset to default theme
  Future<void> resetToDefaults() async {
    _colorMode = ColorMode.light;
    _accentColor = Colors.blue;
    _isCustomColor = false;
    _customColorHex = '#2196F3';
    _keyOpacity = 1.0;
    _keyBorderRadius = 8.0;
    _keyGapSpacing = 4.0;
    _keyShape = KeyShape.rounded;
    _fontFamily = 'Default';
    _fontSize = 16.0;
    _fontWeight = FontWeight.w500;
    _keyboardHeight = 250.0;
    _floatingMode = false;
    _floatingSize = 0.8;
    _rowStagger = false;
    _oneHandedMode = OneHandedMode.off;
    _oneHandedShiftPercent = 30.0;
    _backgroundStyle = BackgroundStyle.solid;
    _backgroundColor = const Color(0xFFE8E8E8);
    _backgroundImagePath = '';
    _keyShadow = true;
    _shadowIntensity = 0.5;
    _soundTheme = SoundTheme.click;
    _vibrationIntensity = 2;
    _keyAnimation = KeyAnimation.scale;
    _emojiStyle = EmojiStyle.system;

    await _saveAllToPreferences();
    notifyListeners();
  }

  // Helper methods
  int _fontWeightToValue(FontWeight weight) {
    const weights = {
      FontWeight.w300: 300,
      FontWeight.w400: 400,
      FontWeight.w500: 500,
      FontWeight.w600: 600,
      FontWeight.w700: 700,
    };
    return weights[weight] ?? 500;
  }

  int _fontWeightToIndex(int value) {
    const map = {300: 0, 400: 1, 500: 2, 600: 3, 700: 4};
    return map[value] ?? 2;
  }

  FontWeight _indexToFontWeight(int index) {
    const weights = [
      FontWeight.w300,
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.w700,
    ];
    return weights[index.clamp(0, weights.length - 1)];
  }

  /// Get keyboard height label
  String getKeyboardHeightLabel() {
    if (_keyboardHeight == 200) return 'Compact';
    if (_keyboardHeight == 250) return 'Normal';
    if (_keyboardHeight == 300) return 'Large';
    if (_keyboardHeight == 350) return 'XL';
    return 'Custom';
  }

  /// Get color mode label
  String getColorModeLabel() {
    switch (_colorMode) {
      case ColorMode.light:
        return 'Light';
      case ColorMode.dark:
        return 'Dark';
      case ColorMode.auto:
        return 'Auto';
    }
  }

  /// Build Material ThemeData from current settings
  ThemeData getThemeData() {
    final isDark = _colorMode == ColorMode.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: _accentColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accentColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: _fontSize + 8,
          fontWeight: _fontWeight,
          color: isDark ? Colors.white : Colors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: _fontSize,
          fontWeight: _fontWeight,
          color: isDark ? Colors.white : Colors.black,
        ),
        bodyMedium: TextStyle(
          fontSize: _fontSize - 2,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  /// Get keyboard background color based on settings
  Color getKeyboardBackgroundColor() {
    return _backgroundColor;
  }
}
