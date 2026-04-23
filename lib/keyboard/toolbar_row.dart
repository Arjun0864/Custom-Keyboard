import 'package:flutter/material.dart';
import 'keyboard_theme.dart';

enum ToolbarAction { emoji, sticker, gif, voice, settings, more }

/// Top toolbar — matches the reference image icons exactly.
class ToolbarRow extends StatelessWidget {
  final ToolbarAction? active;
  final ValueChanged<ToolbarAction> onTap;

  const ToolbarRow({super.key, required this.onTap, this.active});

  static const _items = [
    (ToolbarAction.emoji,    Icons.sentiment_satisfied_alt_outlined),
    (ToolbarAction.sticker,  Icons.sticky_note_2_outlined),
    (ToolbarAction.gif,      Icons.gif_box_outlined),
    (ToolbarAction.voice,    Icons.mic_outlined),
    (ToolbarAction.settings, Icons.settings_outlined),
    (ToolbarAction.more,     Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    final t = KbTheme.of(context);
    return Container(
      height: 44,
      color: t.toolbarBg,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _items.map((item) {
          final (action, icon) = item;
          final isActive = active == action;
          return GestureDetector(
            onTap: () => onTap(action),
            child: SizedBox(
              width: 44, height: 44,
              child: Icon(
                icon,
                size: 24,
                color: isActive ? const Color(0xFF007AFF) : t.toolbarIcon,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
