import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'keyboard_state.dart';

class KeyboardHeightSlider extends ConsumerWidget {
  const KeyboardHeightSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(keyboardStateProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Keyboard Height"),
          Slider(
            value: state.keyboardHeight,
            min: 200,
            max: 400,
            onChanged: (val) => ref.read(keyboardStateProvider.notifier).setKeyboardHeight(val),
          ),
          Text("${state.keyboardHeight.toInt()} dp"),
        ],
      ),
    );
  }
}
