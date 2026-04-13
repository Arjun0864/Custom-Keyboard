import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'keyboard_state.dart';
import 'keyboard_layout.dart';
import 'suggestion_bar_and_chip.dart';
import 'emoji_panel.dart';

class KeyboardScreen extends ConsumerWidget {
  const KeyboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(keyboardStateProvider);

    return Container(
      height: state.keyboardHeight,
      color: state.currentTheme.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Suggestion Bar
          if (state.showSuggestions)
            const SuggestionBar(),
          
          // Main Keyboard Layout
          Expanded(
            child: KeyboardLayout(layer: state.layer),
          ),
          
          // Emoji Panel
          if (state.showEmojiPanel)
            const EmojiPanel(),
        ],
      ),
    );
  }
}
