import '../core/app_constants.dart';

// Re-export KeyboardLayouts so it's accessible from keyboard_screen.dart
export '../core/app_constants.dart' show KeyboardLayouts;

class TransliterationEngine {
  // Extended Hindi transliteration map with vowel matras
  static const Map<String, String> _hindiMap = {
    // Vowels
    'aa': 'आ', 'ii': 'ई', 'uu': 'ऊ', 'ri': 'ऋ',
    'a': 'अ', 'i': 'इ', 'u': 'उ', 'e': 'ए', 'o': 'ओ',
    'ai': 'ऐ', 'au': 'औ', 'am': 'अं', 'ah': 'अः',

    // Consonants with vowels (most specific first)
    'ksha': 'क्ष', 'gya': 'ज्ञ', 'tra': 'त्र',
    'shri': 'श्री',

    // Two-letter combinations
    'kh': 'ख', 'gh': 'घ', 'ch': 'च', 'chh': 'छ',
    'jh': 'झ', 'th': 'थ', 'dh': 'ध', 'ph': 'फ', 'bh': 'भ',
    'sh': 'श', 'nh': 'ण',

    // Single consonants
    'k': 'क', 'g': 'ग', 'j': 'ज', 'z': 'ज़',
    't': 'त', 'd': 'द', 'n': 'न', 'p': 'प', 'b': 'ब',
    'm': 'म', 'y': 'य', 'r': 'र', 'l': 'ल', 'v': 'व',
    'w': 'व', 's': 'स', 'h': 'ह', 'f': 'फ़', 'q': 'क़',
    'x': 'क्स',

    // Special
    '.': '।', '..': '॥', 'om': 'ॐ',
  };

  static const Map<String, String> _gujaratiMap = {
    // Vowels
    'aa': 'આ', 'ii': 'ઈ', 'uu': 'ઊ',
    'a': 'અ', 'i': 'ઇ', 'u': 'ઉ', 'e': 'એ', 'o': 'ઓ',
    'ai': 'ઐ', 'au': 'ઔ',

    // Consonant clusters
    'kh': 'ખ', 'gh': 'ઘ', 'ch': 'ચ', 'chh': 'છ',
    'jh': 'ઝ', 'th': 'થ', 'dh': 'ધ', 'ph': 'ફ', 'bh': 'ભ',
    'sh': 'શ', 'nh': 'ણ',

    // Single consonants
    'k': 'ક', 'g': 'ગ', 'j': 'જ', 'z': 'ઝ',
    't': 'ત', 'd': 'દ', 'n': 'ન', 'p': 'પ', 'b': 'બ',
    'm': 'મ', 'y': 'ય', 'r': 'ર', 'l': 'લ', 'v': 'વ',
    'w': 'વ', 's': 'સ', 'h': 'હ', 'f': 'ફ',

    '.': '।',
  };

  String transliterate(String input, String language) {
    if (input.isEmpty) return input;

    switch (language) {
      case AppConstants.langHindi:
        return _transliterateHindi(input);
      case AppConstants.langGujarati:
        return _transliterateGujarati(input);
      case AppConstants.langHinglish:
        return _transliterateHinglish(input);
      default:
        return input;
    }
  }

  String _transliterateHindi(String input) {
    final lower = input.toLowerCase();
    final result = StringBuffer();
    int i = 0;

    while (i < lower.length) {
      bool matched = false;

      // Try longest match first (up to 4 chars)
      for (int len = 4; len >= 1; len--) {
        if (i + len > lower.length) continue;
        final chunk = lower.substring(i, i + len);
        if (_hindiMap.containsKey(chunk)) {
          result.write(_hindiMap[chunk]);
          i += len;
          matched = true;
          break;
        }
      }

      if (!matched) {
        result.write(lower[i]);
        i++;
      }
    }

    return result.toString();
  }

  String _transliterateGujarati(String input) {
    final lower = input.toLowerCase();
    final result = StringBuffer();
    int i = 0;

    while (i < lower.length) {
      bool matched = false;

      for (int len = 4; len >= 1; len--) {
        if (i + len > lower.length) continue;
        final chunk = lower.substring(i, i + len);
        if (_gujaratiMap.containsKey(chunk)) {
          result.write(_gujaratiMap[chunk]);
          i += len;
          matched = true;
          break;
        }
      }

      if (!matched) {
        result.write(lower[i]);
        i++;
      }
    }

    return result.toString();
  }

  String _transliterateHinglish(String input) {
    // Hinglish: keeps English words, transliterates Hindi words
    // Simple heuristic: words ending in vowels or certain patterns → Hindi
    final words = input.split(' ');
    final result = <String>[];

    for (final word in words) {
      if (_isLikelyHindi(word)) {
        result.add(_transliterateHindi(word));
      } else {
        result.add(word);
      }
    }

    return result.join(' ');
  }

  bool _isLikelyHindi(String word) {
    // Simple heuristic: check if word matches common Hindi patterns
    final hindiPatterns = [
      RegExp(r'(kh|gh|ch|jh|th|dh|ph|bh|sh)'),
      RegExp(r'(aa|ii|uu|ai|au)'),
      RegExp(r'(a|i|u|e|o)$'),
    ];

    return hindiPatterns.any((p) => p.hasMatch(word.toLowerCase()));
  }

  /// Get transliteration suggestions for partial input
  List<String> getSuggestions(String input, String language) {
    if (input.isEmpty) return [];

    final map = language == AppConstants.langGujarati ? _gujaratiMap : _hindiMap;
    final suggestions = <String>[];

    // Direct transliteration
    final direct = transliterate(input, language);
    if (direct != input) {
      suggestions.add(direct);
    }

    // Partial matches - find words that start with the transliteration
    final prefix = input.toLowerCase();
    for (final entry in map.entries) {
      if (entry.key.startsWith(prefix) && entry.key != prefix) {
        suggestions.add(entry.value);
      }
    }

    return suggestions.take(5).toList();
  }
}
