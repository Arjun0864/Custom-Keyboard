import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'keyboard_state.dart';
import '../services/keyboard_service.dart';

class SuggestionBar extends ConsumerWidget {
  const SuggestionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(keyboardStateProvider);
    
    return Container(
      height: 45,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: state.suggestions.isEmpty
          ? Container()
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.suggestions.length,
              itemBuilder: (context, index) {
                return SuggestionChip(
                  text: state.suggestions[index],
                  onTap: () {
                    final keyboardService = ref.read(keyboardChannelServiceProvider);
                    keyboardService.commitText(state.suggestions[index]);
                    ref.read(keyboardStateProvider.notifier).setSuggestions([]);
                  },
                );
              },
            ),
    );
  }
}

class SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SuggestionChip({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
