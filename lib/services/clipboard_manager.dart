import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClipboardItem {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isPinned;

  const ClipboardItem({
    required this.id,
    required this.text,
    required this.timestamp,
    this.isPinned = false,
  });

  ClipboardItem copyWith({bool? isPinned}) => ClipboardItem(
    id: id,
    text: text,
    timestamp: timestamp,
    isPinned: isPinned ?? this.isPinned,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'isPinned': isPinned,
  };

  factory ClipboardItem.fromJson(Map<String, dynamic> json) => ClipboardItem(
    id: json['id'] as String,
    text: json['text'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isPinned: json['isPinned'] as bool? ?? false,
  );
}

final clipboardManagerProvider = StateNotifierProvider<ClipboardManager, List<ClipboardItem>>((ref) {
  return ClipboardManager();
});

class ClipboardManager extends StateNotifier<List<ClipboardItem>> {
  static const _key = 'clipboard_history';
  static const int _maxItems = 50;

  ClipboardManager() : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);
      if (json != null) {
        final list = jsonDecode(json) as List;
        state = list
            .map((item) => ClipboardItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  Future<void> addItem(String text) async {
    if (text.trim().isEmpty) return;

    // Check if already exists
    final existing = state.indexWhere((item) => item.text == text);
    if (existing >= 0) {
      // Move to top
      final item = state[existing];
      final newState = [...state];
      newState.removeAt(existing);
      newState.insert(0, item);
      state = newState;
      await _save();
      return;
    }

    final item = ClipboardItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      timestamp: DateTime.now(),
    );

    final newState = [item, ...state];
    // Respect max limit (keep pinned items)
    final unpinned = newState.where((e) => !e.isPinned).toList();
    final pinned = newState.where((e) => e.isPinned).toList();

    while (unpinned.length > _maxItems - pinned.length) {
      unpinned.removeLast();
    }

    state = [...pinned, ...unpinned];
    await _save();
  }

  Future<void> removeItem(String id) async {
    state = state.where((item) => item.id != id).toList();
    await _save();
  }

  Future<void> togglePin(String id) async {
    state = state.map((item) {
      if (item.id == id) return item.copyWith(isPinned: !item.isPinned);
      return item;
    }).toList();

    // Sort: pinned first
    final pinned = state.where((e) => e.isPinned).toList();
    final unpinned = state.where((e) => !e.isPinned).toList();
    state = [...pinned, ...unpinned];
    await _save();
  }

  Future<void> clearAll({bool keepPinned = true}) async {
    if (keepPinned) {
      state = state.where((e) => e.isPinned).toList();
    } else {
      state = [];
    }
    await _save();
  }

  List<ClipboardItem> search(String query) {
    if (query.isEmpty) return state;
    return state
        .where((item) => item.text.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
