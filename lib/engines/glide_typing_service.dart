import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'suggestion_engine.dart';

final glideTypingServiceProvider = Provider<GlideTypingService>((ref) {
  final suggestionEngine = ref.watch(suggestionEngineProvider);
  return GlideTypingService(suggestionEngine);
});

class GlidePoint {
  final Offset position;
  final String? nearestKey;

  const GlidePoint({required this.position, this.nearestKey});
}

class GlideTypingService {
  final SuggestionEngine _suggestionEngine;
  final List<GlidePoint> _points = [];
  final List<String> _visitedKeys = [];
  String _lastKey = '';

  GlideTypingService(this._suggestionEngine);

  void startGlide(Offset position) {
    _points.clear();
    _visitedKeys.clear();
    _lastKey = '';
  }

  void addPoint(Offset position, Map<String, Rect> keyBounds) {
    _points.add(GlidePoint(position: position));

    // Find nearest key
    final nearest = _findNearestKey(position, keyBounds);
    if (nearest != null && nearest != _lastKey) {
      _visitedKeys.add(nearest);
      _lastKey = nearest;
    }
  }

  String? endGlide(Map<String, Rect> keyBounds, double sensitivity) {
    if (_visitedKeys.length < 2) {
      return _visitedKeys.isNotEmpty ? _visitedKeys.first : null;
    }

    // Build the typed string from visited keys
    final keyString = _visitedKeys.join('').toLowerCase();

    // Find best matching word
    return _findBestMatch(keyString);
  }

  String? _findNearestKey(Offset position, Map<String, Rect> keyBounds) {
    String? nearest;
    double minDistance = double.infinity;

    for (final entry in keyBounds.entries) {
      final center = entry.value.center;
      final distance = (position - center).distance;
      if (distance < minDistance) {
        minDistance = distance;
        nearest = entry.key;
      }
    }
    return nearest;
  }

  String? _findBestMatch(String keyPath) {
    if (keyPath.isEmpty) return null;

    // Use suggestion engine to find matching word
    final suggestions = _suggestionEngine.getSuggestions(
      keyPath.substring(0, min(3, keyPath.length)),
      '',
      limit: 5,
    );

    if (suggestions.isEmpty) return keyPath;

    // Find best matching word based on key path similarity
    String? best;
    double bestScore = 0.0;

    for (final word in suggestions) {
      final score = _pathSimilarity(keyPath, word.toLowerCase());
      if (score > bestScore) {
        bestScore = score;
        best = word;
      }
    }

    return best ?? keyPath;
  }

  double _pathSimilarity(String keyPath, String word) {
    if (word.isEmpty) return 0.0;

    // Compare start and end characters
    double score = 0.0;

    if (keyPath.isNotEmpty && word.isNotEmpty && keyPath[0] == word[0]) {
      score += 0.4;
    }
    if (keyPath.isNotEmpty && word.isNotEmpty &&
        keyPath[keyPath.length - 1] == word[word.length - 1]) {
      score += 0.3;
    }

    // Check common characters
    final keyChars = keyPath.split('').toSet();
    final wordChars = word.split('').toSet();
    final common = keyChars.intersection(wordChars).length;
    score += (common / max(keyChars.length, wordChars.length)) * 0.3;

    return score;
  }

  List<GlidePoint> get currentPoints => List.unmodifiable(_points);
  List<String> get visitedKeys => List.unmodifiable(_visitedKeys);
}
