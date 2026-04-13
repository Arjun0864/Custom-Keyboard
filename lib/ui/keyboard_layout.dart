import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'keyboard_state.dart';
import 'keyboard_row.dart';
import 'keyboard_key.dart';
import '../core/app_constants.dart';

class KeyboardLayout extends ConsumerWidget {
  final KeyboardLayer layer;

  const KeyboardLayout({super.key, KeyboardLayer? layer}) : layer = layer ?? KeyboardLayer.main;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(keyboardStateProvider);

    final keys = _getLayoutForLayer(state.layer, state.isShifted);

    return Column(
      children: [
        for (final row in keys)
          KeyboardRow(
            keys: row
                .map((key) => KeyboardKey(
                  label: state.isShifted && key == key.toLowerCase()
                      ? key.toUpperCase()
                      : key,
                  value: key,
                  isSpecial: _isSpecialKey(key),
                ))
                .toList(),
          ),
      ],
    );
  }

  List<List<String>> _getLayoutForLayer(KeyboardLayer layer, bool isShifted) {
    switch (layer) {
      case KeyboardLayer.main:
        return KeyboardLayouts.englishQwerty;
      case KeyboardLayer.symbols1:
        return KeyboardLayouts.symbols1;
      case KeyboardLayer.symbols2:
        return KeyboardLayouts.symbols2;
      case KeyboardLayer.emoji:
      case KeyboardLayer.clipboard:
      case KeyboardLayer.translator:
      case KeyboardLayer.voice:
        return KeyboardLayouts.englishQwerty;
    }
  }

  bool _isSpecialKey(String key) {
    return ['SHIFT', 'BACKSPACE', 'SPACE', 'ENTER', '123', 'ABC', 'LANG'].contains(key);
  }
}
