class AppConstants {
  static const String methodChannel = 'com.flutterboard/keyboard';
  static const String eventChannel = 'com.flutterboard/keyboard_events';
  static const String inputChannel = 'com.flutterboard/input';
  static const String settingsChannel = 'com.flutterboard/settings';

  // Hive boxes
  static const String settingsBox = 'settings';
  static const String clipboardBox = 'clipboard';
  static const String dictionaryBox = 'dictionary';
  static const String themesBox = 'themes';

  // Default values
  static const double defaultKeyHeight = 48.0;
  static const double defaultKeyBorderRadius = 8.0;
  static const double defaultKeySpacing = 4.0;
  static const double defaultKeyboardHeight = 260.0;
  static const double defaultFontSize = 14.0;
  static const int defaultLongPressDelay = 300;
  static const int defaultHapticStrength = 128;
  static const int defaultHapticDuration = 30;
  static const double defaultSwipeSensitivity = 0.5;

  // Languages
  static const String langEnglish = 'en';
  static const String langHindi = 'hi';
  static const String langGujarati = 'gu';
  static const String langHinglish = 'hinglish';

  // Keyboard modes
  static const String modeNormal = 'normal';
  static const String modeFloat = 'float';
  static const String modeSplit = 'split';
  static const String modeOneHand = 'one_hand';
}

class KeyboardLayouts {
  static final List<List<String>> englishQwerty = [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
    ['SHIFT', 'z', 'x', 'c', 'v', 'b', 'n', 'm', 'BACKSPACE'],
    ['123', 'LANG', 'SPACE', 'ENTER'],
  ];

  static final List<List<String>> numberRow = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
  ];

  static final List<List<String>> symbols1 = [
    ['!', '@', '#', '\$', '%', '^', '&', '*', '(', ')'],
    ['-', '/', ':', ';', '\'', '"', '?', '!', '~', '`'],
    ['SHIFT_SYM', '[', ']', '{', '}', '#', '%', '^', '*', 'BACKSPACE'],
    ['ABC', 'LANG', 'SPACE', 'ENTER'],
  ];

  static final List<List<String>> symbols2 = [
    ['~', '`', '|', '•', '√', '÷', '×', '¶', '∆', '£'],
    ['¥', '€', '¢', '°', '€', '{', '}', '\\', '<', '>'],
    ['SHIFT_SYM', '€', '₹', '\$', '¥', 'Π', 'ψ', '=', '+', 'BACKSPACE'],
    ['ABC', 'LANG', 'SPACE', 'ENTER'],
  ];

  // Transliteration maps for Hindi
  static const Map<String, String> hindiTranslit = {
    'a': 'अ', 'aa': 'आ', 'i': 'इ', 'ee': 'ई', 'u': 'उ',
    'oo': 'ऊ', 'e': 'ए', 'ai': 'ऐ', 'o': 'ओ', 'au': 'औ',
    'ka': 'क', 'kha': 'ख', 'ga': 'ग', 'gha': 'घ', 'nga': 'ङ',
    'cha': 'च', 'chha': 'छ', 'ja': 'ज', 'jha': 'झ', 'nya': 'ञ',
    'ta': 'ट', 'tha': 'ठ', 'da': 'ड', 'dha': 'ढ', 'na': 'ण',
    'ta2': 'त', 'tha2': 'थ', 'da2': 'द', 'dha2': 'ध', 'na2': 'न',
    'pa': 'प', 'pha': 'फ', 'ba': 'ब', 'bha': 'भ', 'ma': 'म',
    'ya': 'य', 'ra': 'र', 'la': 'ल', 'va': 'व', 'sha': 'श',
    'shha': 'ष', 'sa': 'स', 'ha': 'ह',
    'k': 'क', 'kh': 'ख', 'g': 'ग', 'gh': 'घ',
    'ch': 'च', 'j': 'ज', 'jh': 'झ',
    't': 'त', 'th': 'थ', 'd': 'द', 'dh': 'ध', 'n': 'न',
    'p': 'प', 'ph': 'फ', 'b': 'ब', 'bh': 'भ', 'm': 'म',
    'y': 'य', 'r': 'र', 'l': 'ल', 'v': 'व', 'w': 'व',
    'sh': 'श', 's': 'स', 'h': 'ह', 'f': 'फ', 'z': 'ज',
  };

  // Transliteration maps for Gujarati
  static const Map<String, String> gujaratiTranslit = {
    'a': 'અ', 'aa': 'આ', 'i': 'ઇ', 'ee': 'ઈ', 'u': 'ઉ',
    'oo': 'ઊ', 'e': 'એ', 'ai': 'ઐ', 'o': 'ઓ', 'au': 'ઔ',
    'ka': 'ક', 'kha': 'ખ', 'ga': 'ગ', 'gha': 'ઘ',
    'cha': 'ચ', 'chha': 'છ', 'ja': 'જ', 'jha': 'ઝ',
    'ta': 'ટ', 'tha': 'ઠ', 'da': 'ડ', 'dha': 'ઢ', 'na': 'ણ',
    'ta2': 'ત', 'tha2': 'થ', 'da2': 'દ', 'dha2': 'ધ', 'na2': 'ન',
    'pa': 'પ', 'pha': 'ફ', 'ba': 'બ', 'bha': 'ભ', 'ma': 'મ',
    'ya': 'ય', 'ra': 'ર', 'la': 'લ', 'va': 'વ', 'sha': 'શ',
    'sa': 'સ', 'ha': 'હ',
    'k': 'ક', 'kh': 'ખ', 'g': 'ગ', 'gh': 'ઘ',
    'ch': 'ચ', 'j': 'જ', 'jh': 'ઝ',
    't': 'ત', 'th': 'થ', 'd': 'દ', 'dh': 'ધ', 'n': 'ન',
    'p': 'પ', 'ph': 'ફ', 'b': 'બ', 'bh': 'ભ', 'm': 'મ',
    'y': 'ય', 'r': 'ર', 'l': 'લ', 'v': 'વ', 'w': 'વ',
    'sh': 'શ', 's': 'સ', 'h': 'હ', 'f': 'ફ', 'z': 'ઝ',
  };
}
