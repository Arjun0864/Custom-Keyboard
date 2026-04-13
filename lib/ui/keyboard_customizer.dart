import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'keyboard_state.dart';

class KeyboardCustomizer extends ConsumerWidget {
  const KeyboardCustomizer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(keyboardStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customize Keyboard"),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Key Appearance",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ListTile(
            title: const Text("Key Color"),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: state.currentTheme.keyColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          ListTile(
            title: const Text("Text Color"),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: state.currentTheme.keyTextColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          ListTile(
            title: const Text("Special Key Color"),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: state.currentTheme.specialKeyColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Layout",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SwitchListTile(
            title: const Text("Show Number Row"),
            value: false,
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text("Show Emoji Button"),
            value: state.showEmojiPanel,
            onChanged: (val) {
              ref.read(keyboardStateProvider.notifier).toggleEmojiPanel();
            },
          ),
        ],
      ),
    );
  }
}
