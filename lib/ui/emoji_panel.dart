import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'keyboard_state.dart';
import '../services/keyboard_service.dart';

class EmojiCategory {
  final String name;
  final List<String> emojis;

  const EmojiCategory({required this.name, required this.emojis});
}

const List<EmojiCategory> emojiCategories = [
  EmojiCategory(name: 'Smileys', emojis: ['😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇']),
  EmojiCategory(name: 'Animals', emojis: ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯']),
  EmojiCategory(name: 'Food', emojis: ['🍎', '🍌', '🍊', '🍋', '🍉', '🍇', '🍓', '🍈', '🍒', '🍑']),
  // Add more categories as needed
];

class EmojiPanel extends ConsumerStatefulWidget {
  const EmojiPanel({super.key});

  @override
  ConsumerState<EmojiPanel> createState() => _EmojiPanelState();
}

class _EmojiPanelState extends ConsumerState<EmojiPanel> {
  String selectedCategory = 'Smileys';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(keyboardStateProvider);
    final currentCategory = emojiCategories.firstWhere(
      (cat) => cat.name == selectedCategory,
      orElse: () => emojiCategories.first,
    );
    
    return Container(
      height: 250,
      color: state.currentTheme.backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: currentCategory.emojis.length,
              itemBuilder: (context, index) {
                final emoji = currentCategory.emojis[index];
                return GestureDetector(
                  onTap: () {
                    ref.read(keyboardChannelServiceProvider)
                        .commitText(emoji);
                  },
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 40,
            color: Colors.grey[200],
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: emojiCategories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextButton(
                    onPressed: () {
                      setState(() => selectedCategory = category.name);
                    },
                    child: Text(category.name),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
