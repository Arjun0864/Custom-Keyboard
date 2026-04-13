import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final suggestionEngineProvider = Provider<SuggestionEngine>((ref) {
  return SuggestionEngine();
});

final suggestionsProvider = StateProvider<List<String>>((ref) => []);

class SuggestionEngine {
  // N-gram model for next word prediction
  final Map<String, Map<String, int>> _bigrams = {};
  final Map<String, int> _wordFrequency = {};
  final Map<String, String> _corrections = {};
  final Set<String> _customDictionary = {};

  // Common English words for basic prediction
  static const _baseVocabulary = [
    'the', 'be', 'to', 'of', 'and', 'a', 'in', 'that', 'have', 'it',
    'for', 'not', 'on', 'with', 'he', 'as', 'you', 'do', 'at', 'this',
    'but', 'his', 'by', 'from', 'they', 'we', 'say', 'her', 'she', 'or',
    'an', 'will', 'my', 'one', 'all', 'would', 'there', 'their', 'what',
    'so', 'up', 'out', 'if', 'about', 'who', 'get', 'which', 'go', 'me',
    'when', 'make', 'can', 'like', 'time', 'no', 'just', 'him', 'know',
    'take', 'people', 'into', 'year', 'your', 'good', 'some', 'could',
    'them', 'see', 'other', 'than', 'then', 'now', 'look', 'only', 'come',
    'its', 'over', 'think', 'also', 'back', 'after', 'use', 'two', 'how',
    'our', 'work', 'first', 'well', 'way', 'even', 'new', 'want', 'because',
    'any', 'these', 'give', 'day', 'most', 'us', 'great', 'between', 'need',
    'large', 'often', 'hand', 'high', 'place', 'hold', 'turn', 'yes',
    'hello', 'thanks', 'please', 'sorry', 'okay', 'yes', 'no', 'help',
    'love', 'home', 'school', 'work', 'food', 'water', 'phone', 'email',
    'message', 'morning', 'evening', 'night', 'today', 'tomorrow', 'week',
    'month', 'year', 'happy', 'sad', 'excited', 'beautiful', 'amazing',
  ];

  // Common bigrams (word pairs)
  static const _baseBigrams = <String, List<String>>{
    'i': ['am', 'will', 'have', 'want', 'think', 'can', 'would', 'need'],
    'you': ['are', 'can', 'will', 'have', 'know', 'should', 'need', 'want'],
    'the': ['best', 'first', 'last', 'only', 'same', 'most', 'next', 'new'],
    'how': ['are', 'is', 'do', 'can', 'much', 'many', 'long', 'far'],
    'what': ['is', 'are', 'do', 'you', 'the', 'time', 'about', 'if'],
    'thank': ['you', 'you so', 'you very'],
    'good': ['morning', 'night', 'evening', 'luck', 'bye', 'job', 'work'],
    'have': ['a', 'you', 'been', 'to', 'the', 'some', 'any', 'fun'],
    'going': ['to', 'on', 'well', 'great', 'back', 'home', 'out', 'up'],
    'can': ['you', 'we', 'i', 'be', 'do', 'help', 'get', 'see'],
    'in': ['the', 'a', 'my', 'your', 'this', 'that', 'some', 'any'],
    'on': ['the', 'my', 'your', 'this', 'that', 'it', 'a', 'time'],
  };

  // Auto-correction dictionary
  static const _defaultCorrections = <String, String>{
    'teh': 'the', 'adn': 'and', 'fo': 'of', 'hte': 'the',
    'nad': 'and', 'ahve': 'have', 'recieve': 'receive',
    'occured': 'occurred', 'seperate': 'separate', 'definately': 'definitely',
    'wierd': 'weird', 'freind': 'friend', 'privelege': 'privilege',
    'accomodate': 'accommodate', 'alot': 'a lot', 'cant': "can't",
    'dont': "don't", 'wont': "won't", 'isnt': "isn't", 'didnt': "didn't",
    'thier': 'their', 'becuase': 'because', 'untill': 'until',
    'reccomend': 'recommend', 'adress': 'address', 'beleive': 'believe',
  };

  SuggestionEngine() {
    _initializeBase();
    _loadCustomDictionary();
  }

  void _initializeBase() {
    // Load base vocabulary frequencies
    for (final word in _baseVocabulary) {
      _wordFrequency[word] = 100;
    }

    // Load base bigrams
    _baseBigrams.forEach((word, nextWords) {
      _bigrams[word] = {};
      for (int i = 0; i < nextWords.length; i++) {
        _bigrams[word]![nextWords[i]] = (nextWords.length - i) * 10;
      }
    });

    // Load default corrections
    _corrections.addAll(_defaultCorrections);
  }

  Future<void> _loadCustomDictionary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('custom_dictionary');
      if (json != null) {
        final list = jsonDecode(json) as List;
        _customDictionary.addAll(list.cast<String>());
        for (final word in _customDictionary) {
          _wordFrequency[word] = (_wordFrequency[word] ?? 0) + 200;
        }
      }
    } catch (_) {}
  }

  /// Get suggestions for current word being typed
  List<String> getSuggestions(String currentWord, String previousWord, {int limit = 3}) {
    if (currentWord.isEmpty && previousWord.isEmpty) return [];

    final suggestions = <String>[];

    if (currentWord.isNotEmpty) {
      // Auto-correction first
      final correction = getCorrection(currentWord);
      if (correction != null && correction != currentWord) {
        suggestions.add(correction);
      }

      // Prefix completions
      final completions = _getPrefixCompletions(currentWord.toLowerCase());
      suggestions.addAll(completions.take(limit - suggestions.length));
    } else if (previousWord.isNotEmpty) {
      // Next word prediction
      final nextWords = _getNextWordPredictions(previousWord.toLowerCase());
      suggestions.addAll(nextWords.take(limit));
    }

    // Remove duplicates and return
    return suggestions.toSet().toList().take(limit).toList();
  }

  /// Get auto-correction for a word
  String? getCorrection(String word) {
    final lower = word.toLowerCase();
    // Direct correction lookup
    if (_corrections.containsKey(lower)) {
      return _corrections[lower];
    }
    // Check edit distance 1 for common mistakes
    return _findClosestWord(lower);
  }

  List<String> _getPrefixCompletions(String prefix) {
    final matches = <MapEntry<String, int>>[];

    for (final entry in _wordFrequency.entries) {
      if (entry.key.startsWith(prefix) && entry.key != prefix) {
        matches.add(entry);
      }
    }

    // Sort by frequency
    matches.sort((a, b) => b.value.compareTo(a.value));
    return matches.map((e) => e.key).toList();
  }

  List<String> _getNextWordPredictions(String word) {
    final bigram = _bigrams[word];
    if (bigram == null || bigram.isEmpty) {
      // Fall back to frequency-based suggestions
      return _getTopFrequencyWords(3);
    }

    final sorted = bigram.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }

  List<String> _getTopFrequencyWords(int n) {
    final sorted = _wordFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).map((e) => e.key).toList();
  }

  String? _findClosestWord(String word) {
    if (word.length < 3) return null;

    String? closest;
    int minDistance = 2; // Max edit distance for corrections

    for (final dictWord in _wordFrequency.keys) {
      if ((dictWord.length - word.length).abs() > 2) continue;
      final distance = _editDistance(word, dictWord);
      if (distance < minDistance) {
        minDistance = distance;
        closest = dictWord;
      }
    }
    return closest;
  }

  int _editDistance(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;
    final dp = List.generate(m + 1, (i) => List.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]].reduce((a, b) => a < b ? a : b);
        }
      }
    }
    return dp[m][n];
  }

  /// Learn from user's typing
  void learnWord(String word, {String? previousWord}) {
    if (word.isEmpty || word.length < 2) return;

    final lower = word.toLowerCase();
    _wordFrequency[lower] = (_wordFrequency[lower] ?? 0) + 1;

    if (previousWord != null && previousWord.isNotEmpty) {
      final prevLower = previousWord.toLowerCase();
      _bigrams[prevLower] ??= {};
      _bigrams[prevLower]![lower] = (_bigrams[prevLower]![lower] ?? 0) + 1;
    }
  }

  /// Add word to custom dictionary
  Future<void> addToCustomDictionary(String word) async {
    _customDictionary.add(word);
    _wordFrequency[word] = (_wordFrequency[word] ?? 0) + 200;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_dictionary', jsonEncode(_customDictionary.toList()));
  }

  /// Add custom correction
  void addCorrection(String wrong, String correct) {
    _corrections[wrong.toLowerCase()] = correct;
  }
}
