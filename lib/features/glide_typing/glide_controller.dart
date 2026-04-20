import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'word_dictionary.dart';

/// Represents a key position on the keyboard
class KeyPosition {
  final String character;
  final Offset center;
  final double width;
  final double height;

  KeyPosition({
    required this.character,
    required this.center,
    required this.width,
    required this.height,
  });

  /// Check if a point is within this key's bounds
  bool contains(Offset point) {
    return point.dx >= center.dx - width / 2 &&
        point.dx <= center.dx + width / 2 &&
        point.dy >= center.dy - height / 2 &&
        point.dy <= center.dy + height / 2;
  }

  /// Get distance from point to key center
  double distanceTo(Offset point) {
    return (center - point).distance;
  }
}

/// Represents a touch point during glide typing
class TouchPoint {
  final Offset position;
  final DateTime timestamp;

  TouchPoint({
    required this.position,
    required this.timestamp,
  });
}

/// Word suggestion result
class WordSuggestion {
  final String word;
  final double score;
  final int position;

  WordSuggestion({
    required this.word,
    required this.score,
    required this.position,
  });

  @override
  String toString() => '$word (${score.toStringAsFixed(1)}%)';
}

/// Controller for glide typing / swipe input feature
///
/// Manages:
/// - Finger tracking during swipe
/// - Key detection along the swipe path
/// - Word matching and suggestions
/// - Final word selection
///
/// Usage:
/// ```dart
/// final glideController = GlideController();
/// 
/// // When keyboard layout is known, register key positions
/// glideController.registerKeyPositions(keyPositions);
/// 
/// // Track touch movement
/// glideController.startGlide(touchPoint);
/// glideController.updateGlide(touchPoint);
/// 
/// // Get suggestions
/// final suggestions = glideController.getCurrentSuggestions();
/// 
/// // End glide and get result
/// final bestWord = glideController.endGlide();
/// ```
class GlideController extends ChangeNotifier {
  /// Registered key positions on the keyboard
  Map<String, KeyPosition> _keyPositions = {};

  /// Current touch points during glide
  List<TouchPoint> _touchPath = [];

  /// Characters detected along the path
  List<String> _pathCharacters = [];

  /// Current word suggestions
  List<WordSuggestion> _suggestions = [];

  /// Whether currently gliding
  bool _isGliding = false;

  /// Minimum distance threshold for detecting a new key
  static const double keyDetectionThreshold = 20.0;

  /// Minimum path length to attempt word matching
  static const int minPathLength = 2;

  /// Callback when suggestions change
  Function(List<WordSuggestion>)? onSuggestionsChanged;

  /// Callback when glide starts
  Function()? onGlideStart;

  /// Callback when glide ends
  Function(String)? onGlideEnd;

  // Getters
  bool get isGliding => _isGliding;
  List<String> get pathCharacters => List.unmodifiable(_pathCharacters);
  List<WordSuggestion> get suggestions => List.unmodifiable(_suggestions);
  String get currentPath => _pathCharacters.join();

  /// Register keyboard key positions
  ///
  /// Must be called with the positions of all keys on the keyboard
  /// before glide typing can work
  void registerKeyPositions(Map<String, KeyPosition> positions) {
    _keyPositions = positions;
  }

  /// Start a glide swipe operation
  ///
  /// Call when user touches down on the keyboard
  void startGlide(Offset touchPoint) {
    if (_isGliding) return;

    _isGliding = true;
    _touchPath = [
      TouchPoint(
        position: touchPoint,
        timestamp: DateTime.now(),
      )
    ];
    _pathCharacters = [];
    _suggestions = [];

    // Detect initial key
    _detectKeyAtPoint(touchPoint);

    onGlideStart?.call();
    notifyListeners();
  }

  /// Update glide position during swipe
  ///
  /// Call continuously as user moves finger
  void updateGlide(Offset touchPoint) {
    if (!_isGliding) return;

    // Add new touch point
    _touchPath.add(
      TouchPoint(
        position: touchPoint,
        timestamp: DateTime.now(),
      )
    );

    // Check if we've moved far enough to detect a new key
    final lastTouchPoint = _touchPath[_touchPath.length - 2];
    final distance = (touchPoint - lastTouchPoint.position).distance;

    if (distance >= keyDetectionThreshold) {
      _detectKeyAtPoint(touchPoint);
    }

    // Update suggestions
    _updateSuggestions();
    notifyListeners();
  }

  /// End the glide operation and return the best match word
  ///
  /// Call when user lifts finger
  String endGlide() {
    if (!_isGliding) return '';

    _isGliding = false;

    // Get best match word
    final bestWord = _getBestMatchWord();

    // Trigger callback
    onGlideEnd?.call(bestWord);

    // Clear state
    _touchPath = [];
    _pathCharacters = [];
    _suggestions = [];

    notifyListeners();

    return bestWord;
  }

  /// Cancel the current glide operation
  void cancelGlide() {
    if (!_isGliding) return;

    _isGliding = false;
    _touchPath = [];
    _pathCharacters = [];
    _suggestions = [];

    notifyListeners();
  }

  /// Detect which key is at the given touch point
  void _detectKeyAtPoint(Offset point) {
    // Find the closest key to the touch point
    KeyPosition? closestKey;
    double closestDistance = double.infinity;

    _keyPositions.forEach((character, position) {
      final distance = position.distanceTo(point);
      if (distance < closestDistance) {
        closestDistance = distance;
        closestKey = position;
      }
    });

    if (closestKey != null && closestDistance < keyDetectionThreshold * 2) {
      // Add key only if it's not the last character (avoid duplicates)
      if (_pathCharacters.isEmpty ||
          _pathCharacters.last != closestKey!.character) {
        _pathCharacters.add(closestKey!.character);
      }
    }
  }

  /// Update word suggestions based on current path
  void _updateSuggestions() {
    if (_pathCharacters.length < minPathLength) {
      _suggestions = [];
      onSuggestionsChanged?.call(_suggestions);
      return;
    }

    final path = _pathCharacters.join();

    // Find matching words
    final matches =
        WordDictionary.findMatchingWords(path, limit: 3, minScore: 25.0);

    // Convert to suggestions
    _suggestions = matches
        .asMap()
        .entries
        .map((entry) {
          return WordSuggestion(
            word: entry.value.key,
            score: entry.value.value,
            position: entry.key,
          );
        })
        .toList();

    onSuggestionsChanged?.call(_suggestions);
  }

  /// Get the best matching word from current path
  String _getBestMatchWord() {
    if (_pathCharacters.length < minPathLength) {
      return '';
    }

    final path = _pathCharacters.join();
    final matches = WordDictionary.findMatchingWords(path, limit: 1, minScore: 25.0);

    if (matches.isEmpty) {
      // If no good matches, return the character sequence as fallback
      return path;
    }

    return matches.first.key;
  }

  /// Get current suggestions
  List<WordSuggestion> getCurrentSuggestions() {
    return _suggestions;
  }

  /// Get top N suggestions
  List<String> getTopSuggestions({int count = 3}) {
    return _suggestions
        .take(count)
        .map((s) => s.word)
        .toList();
  }

  /// Get the path as a sequence of characters
  String getPathAsString() {
    return _pathCharacters.join();
  }

  /// Get detailed diagnostics about current glide state
  Map<String, dynamic> getDiagnostics() {
    return {
      'isGliding': _isGliding,
      'touchPathLength': _touchPath.length,
      'pathCharacters': _pathCharacters.length,
      'currentPath': getPathAsString(),
      'suggestionsCount': _suggestions.length,
      'topSuggestion':
          _suggestions.isNotEmpty ? _suggestions.first.word : 'none',
      'registeredKeysCount': _keyPositions.length,
      'suggestions': _suggestions.map((s) => s.toString()).toList(),
    };
  }

  /// Debug: print current path and suggestions
  void debugPrintState() {
    debugPrint('=== GlideController State ===');
    debugPrint('Gliding: $_isGliding');
    debugPrint('Path: ${getPathAsString()}');
    debugPrint('Touch points: ${_touchPath.length}');
    debugPrint('Suggestions:');
    for (final suggestion in _suggestions) {
      debugPrint('  - ${suggestion.word} (${suggestion.score.toStringAsFixed(1)}%)');
    }
  }

  @override
  void dispose() {
    cancelGlide();
    super.dispose();
  }
}

/// Extension to help register key positions from KeyboardWidget
extension GlideControllerExt on GlideController {
  /// Helper method to register key positions for QWERTY layout
  /// 
  /// Call this after building the keyboard
  void registerQwertyLayout({
    required double startX,
    required double startY,
    required double keyWidth,
    required double keyHeight,
    required double spacing,
  }) {
    final positions = <String, KeyPosition>{};

    // QWERTY layout
    const rows = [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
    ];

    double y = startY;
    for (final row in rows) {
      double x = startX;
      for (final char in row) {
        positions[char] = KeyPosition(
          character: char,
          center: Offset(x + keyWidth / 2, y + keyHeight / 2),
          width: keyWidth,
          height: keyHeight,
        );
        x += keyWidth + spacing;
      }
      y += keyHeight + spacing;
    }

    registerKeyPositions(positions);
  }
}
