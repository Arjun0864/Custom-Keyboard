import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_constants.dart';

class KeyboardSettings {
  // Layout
  final double keyboardHeight;
  final double keyboardWidth; // 0.0 = full width
  final bool showNumberRow;
  final bool showEmojiRow;
  final bool showSymbolRow;
  final String keyboardMode; // normal, float, split, one_hand
  final String oneHandSide; // left, right

  // Key Sizing
  final double keyHeight;
  final double keySpacing;
  final double keyBorderRadius;
  final double fontSize;
  final bool boldFont;
  final String fontFamily;

  // Visual
  final int themeIndex;
  final bool keyAnimation;
  final bool keyShadow;
  final double keyTransparency;
  final bool backgroundBlur;
  final String? backgroundImagePath;

  // Interaction
  final double swipeSensitivity;
  final int longPressDelay;
  final int hapticStrength;
  final int hapticDuration;
  final bool hapticEnabled;
  final bool soundEnabled;
  final double soundVolume;

  // Language
  final String currentLanguage;
  final List<String> enabledLanguages;

  // Smart features
  final bool autoCorrect;
  final bool showSuggestions;
  final bool nextWordPrediction;
  final bool emojiSuggestions;
  final bool glideTyping;

  // Behavior
  final bool autoCapitalize;
  final bool doubleSpacePeriod;
  final bool incognitoMode;
  final bool showCursorControl;

  // Voice
  final bool voiceTypingEnabled;

  KeyboardSettings({
    this.keyboardHeight = AppConstants.defaultKeyboardHeight,
    this.keyboardWidth = 0.0,
    this.showNumberRow = false,
    this.showEmojiRow = false,
    this.showSymbolRow = false,
    this.keyboardMode = AppConstants.modeNormal,
    this.oneHandSide = 'right',
    this.keyHeight = AppConstants.defaultKeyHeight,
    this.keySpacing = AppConstants.defaultKeySpacing,
    this.keyBorderRadius = AppConstants.defaultKeyBorderRadius,
    this.fontSize = AppConstants.defaultFontSize,
    this.boldFont = false,
    this.fontFamily = 'NotoSans',
    this.themeIndex = 0,
    this.keyAnimation = true,
    this.keyShadow = true,
    this.keyTransparency = 1.0,
    this.backgroundBlur = false,
    this.backgroundImagePath,
    this.swipeSensitivity = 0.5,
    this.longPressDelay = AppConstants.defaultLongPressDelay,
    this.hapticStrength = AppConstants.defaultHapticStrength,
    this.hapticDuration = AppConstants.defaultHapticDuration,
    this.hapticEnabled = true,
    this.soundEnabled = false,
    this.soundVolume = 0.5,
    this.currentLanguage = AppConstants.langEnglish,
    this.enabledLanguages = const [AppConstants.langEnglish],
    this.autoCorrect = true,
    this.showSuggestions = true,
    this.nextWordPrediction = true,
    this.emojiSuggestions = true,
    this.glideTyping = true,
    this.autoCapitalize = true,
    this.doubleSpacePeriod = true,
    this.incognitoMode = false,
    this.showCursorControl = false,
    this.voiceTypingEnabled = true,
  });

  KeyboardSettings copyWith({
    double? keyboardHeight,
    double? keyboardWidth,
    bool? showNumberRow,
    bool? showEmojiRow,
    bool? showSymbolRow,
    String? keyboardMode,
    String? oneHandSide,
    double? keyHeight,
    double? keySpacing,
    double? keyBorderRadius,
    double? fontSize,
    bool? boldFont,
    String? fontFamily,
    int? themeIndex,
    bool? keyAnimation,
    bool? keyShadow,
    double? keyTransparency,
    bool? backgroundBlur,
    String? backgroundImagePath,
    double? swipeSensitivity,
    int? longPressDelay,
    int? hapticStrength,
    int? hapticDuration,
    bool? hapticEnabled,
    bool? soundEnabled,
    double? soundVolume,
    String? currentLanguage,
    List<String>? enabledLanguages,
    bool? autoCorrect,
    bool? showSuggestions,
    bool? nextWordPrediction,
    bool? emojiSuggestions,
    bool? glideTyping,
    bool? autoCapitalize,
    bool? doubleSpacePeriod,
    bool? incognitoMode,
    bool? showCursorControl,
    bool? voiceTypingEnabled,
  }) {
    return KeyboardSettings(
      keyboardHeight: keyboardHeight ?? this.keyboardHeight,
      keyboardWidth: keyboardWidth ?? this.keyboardWidth,
      showNumberRow: showNumberRow ?? this.showNumberRow,
      showEmojiRow: showEmojiRow ?? this.showEmojiRow,
      showSymbolRow: showSymbolRow ?? this.showSymbolRow,
      keyboardMode: keyboardMode ?? this.keyboardMode,
      oneHandSide: oneHandSide ?? this.oneHandSide,
      keyHeight: keyHeight ?? this.keyHeight,
      keySpacing: keySpacing ?? this.keySpacing,
      keyBorderRadius: keyBorderRadius ?? this.keyBorderRadius,
      fontSize: fontSize ?? this.fontSize,
      boldFont: boldFont ?? this.boldFont,
      fontFamily: fontFamily ?? this.fontFamily,
      themeIndex: themeIndex ?? this.themeIndex,
      keyAnimation: keyAnimation ?? this.keyAnimation,
      keyShadow: keyShadow ?? this.keyShadow,
      keyTransparency: keyTransparency ?? this.keyTransparency,
      backgroundBlur: backgroundBlur ?? this.backgroundBlur,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      swipeSensitivity: swipeSensitivity ?? this.swipeSensitivity,
      longPressDelay: longPressDelay ?? this.longPressDelay,
      hapticStrength: hapticStrength ?? this.hapticStrength,
      hapticDuration: hapticDuration ?? this.hapticDuration,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      currentLanguage: currentLanguage ?? this.currentLanguage,
      enabledLanguages: enabledLanguages ?? this.enabledLanguages,
      autoCorrect: autoCorrect ?? this.autoCorrect,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      nextWordPrediction: nextWordPrediction ?? this.nextWordPrediction,
      emojiSuggestions: emojiSuggestions ?? this.emojiSuggestions,
      glideTyping: glideTyping ?? this.glideTyping,
      autoCapitalize: autoCapitalize ?? this.autoCapitalize,
      doubleSpacePeriod: doubleSpacePeriod ?? this.doubleSpacePeriod,
      incognitoMode: incognitoMode ?? this.incognitoMode,
      showCursorControl: showCursorControl ?? this.showCursorControl,
      voiceTypingEnabled: voiceTypingEnabled ?? this.voiceTypingEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'keyboardHeight': keyboardHeight,
    'keyboardWidth': keyboardWidth,
    'showNumberRow': showNumberRow,
    'showEmojiRow': showEmojiRow,
    'showSymbolRow': showSymbolRow,
    'keyboardMode': keyboardMode,
    'oneHandSide': oneHandSide,
    'keyHeight': keyHeight,
    'keySpacing': keySpacing,
    'keyBorderRadius': keyBorderRadius,
    'fontSize': fontSize,
    'boldFont': boldFont,
    'fontFamily': fontFamily,
    'themeIndex': themeIndex,
    'keyAnimation': keyAnimation,
    'keyShadow': keyShadow,
    'keyTransparency': keyTransparency,
    'backgroundBlur': backgroundBlur,
    'backgroundImagePath': backgroundImagePath,
    'swipeSensitivity': swipeSensitivity,
    'longPressDelay': longPressDelay,
    'hapticStrength': hapticStrength,
    'hapticDuration': hapticDuration,
    'hapticEnabled': hapticEnabled,
    'soundEnabled': soundEnabled,
    'soundVolume': soundVolume,
    'currentLanguage': currentLanguage,
    'enabledLanguages': enabledLanguages,
    'autoCorrect': autoCorrect,
    'showSuggestions': showSuggestions,
    'nextWordPrediction': nextWordPrediction,
    'emojiSuggestions': emojiSuggestions,
    'glideTyping': glideTyping,
    'autoCapitalize': autoCapitalize,
    'doubleSpacePeriod': doubleSpacePeriod,
    'incognitoMode': incognitoMode,
    'showCursorControl': showCursorControl,
    'voiceTypingEnabled': voiceTypingEnabled,
  };

  factory KeyboardSettings.fromJson(Map<String, dynamic> json) => KeyboardSettings(
    keyboardHeight: (json['keyboardHeight'] as num?)?.toDouble() ?? AppConstants.defaultKeyboardHeight,
    keyboardWidth: (json['keyboardWidth'] as num?)?.toDouble() ?? 0.0,
    showNumberRow: json['showNumberRow'] as bool? ?? false,
    showEmojiRow: json['showEmojiRow'] as bool? ?? false,
    showSymbolRow: json['showSymbolRow'] as bool? ?? false,
    keyboardMode: json['keyboardMode'] as String? ?? AppConstants.modeNormal,
    oneHandSide: json['oneHandSide'] as String? ?? 'right',
    keyHeight: (json['keyHeight'] as num?)?.toDouble() ?? AppConstants.defaultKeyHeight,
    keySpacing: (json['keySpacing'] as num?)?.toDouble() ?? AppConstants.defaultKeySpacing,
    keyBorderRadius: (json['keyBorderRadius'] as num?)?.toDouble() ?? AppConstants.defaultKeyBorderRadius,
    fontSize: (json['fontSize'] as num?)?.toDouble() ?? AppConstants.defaultFontSize,
    boldFont: json['boldFont'] as bool? ?? false,
    fontFamily: json['fontFamily'] as String? ?? 'NotoSans',
    themeIndex: json['themeIndex'] as int? ?? 0,
    keyAnimation: json['keyAnimation'] as bool? ?? true,
    keyShadow: json['keyShadow'] as bool? ?? true,
    keyTransparency: (json['keyTransparency'] as num?)?.toDouble() ?? 1.0,
    backgroundBlur: json['backgroundBlur'] as bool? ?? false,
    backgroundImagePath: json['backgroundImagePath'] as String?,
    swipeSensitivity: (json['swipeSensitivity'] as num?)?.toDouble() ?? 0.5,
    longPressDelay: json['longPressDelay'] as int? ?? AppConstants.defaultLongPressDelay,
    hapticStrength: json['hapticStrength'] as int? ?? AppConstants.defaultHapticStrength,
    hapticDuration: json['hapticDuration'] as int? ?? AppConstants.defaultHapticDuration,
    hapticEnabled: json['hapticEnabled'] as bool? ?? true,
    soundEnabled: json['soundEnabled'] as bool? ?? false,
    soundVolume: (json['soundVolume'] as num?)?.toDouble() ?? 0.5,
    currentLanguage: json['currentLanguage'] as String? ?? AppConstants.langEnglish,
    enabledLanguages: (json['enabledLanguages'] as List<dynamic>?)?.cast<String>() ?? [AppConstants.langEnglish],
    autoCorrect: json['autoCorrect'] as bool? ?? true,
    showSuggestions: json['showSuggestions'] as bool? ?? true,
    nextWordPrediction: json['nextWordPrediction'] as bool? ?? true,
    emojiSuggestions: json['emojiSuggestions'] as bool? ?? true,
    glideTyping: json['glideTyping'] as bool? ?? true,
    autoCapitalize: json['autoCapitalize'] as bool? ?? true,
    doubleSpacePeriod: json['doubleSpacePeriod'] as bool? ?? true,
    incognitoMode: json['incognitoMode'] as bool? ?? false,
    showCursorControl: json['showCursorControl'] as bool? ?? false,
    voiceTypingEnabled: json['voiceTypingEnabled'] as bool? ?? true,
  );
}

// ---- Settings Repository ----
final keyboardSettingsProvider = StateNotifierProvider<KeyboardSettingsNotifier, KeyboardSettings>((ref) {
  return KeyboardSettingsNotifier();
});

class KeyboardSettingsNotifier extends StateNotifier<KeyboardSettings> {
  static const _key = 'keyboard_settings';

  KeyboardSettingsNotifier() : super(KeyboardSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      state = KeyboardSettings.fromJson(jsonDecode(json));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  Future<void> update(KeyboardSettings settings) async {
    state = settings;
    await _save();
  }

  Future<void> updateField(KeyboardSettings Function(KeyboardSettings) updater) async {
    state = updater(state);
    await _save();
  }

  Future<void> reset() async {
    state = KeyboardSettings();
    await _save();
  }
}
