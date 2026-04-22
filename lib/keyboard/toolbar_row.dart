import 'package:flutter/material.dart';
import 'keyboard_theme.dart';

enum ToolbarAction { translate, voice, handwrite, clipboard, emoji, settings }

/// Samsung One UI top toolbar row.
class ToolbarRow extends StatelessWidget {
  final ToolbarAction? activeAction;
  final ValueChanged<ToolbarAction> onAction;

  const ToolbarRow({
    super.key,
    required this.onAction,
    this.activeAction,
  });

  static const _items = [
    (ToolbarAction.translate, Icons.g_translate),
    (ToolbarAction.voice,     Icons.mic_none),
    (ToolbarAction.handwrite, Icons.gesture),
    (ToolbarAction.clipboard, Icons.content_paste_outlined),
    (ToolbarAction.emoji,     Icons.emoji_emotions_outlined),
    (ToolbarAction.settings,  Icons.more_vert),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = KbColors.of(context);
    return Container(
      height: 40,
      color: colors.toolbarBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _items.map((item) {
          final (action, icon) = item;
          final isActive = activeAction == action;
          return IconButton(
            onPressed: () => onAction(action),
            icon: Icon(icon, size: 22),
            color: isActive ? colors.accentBlue : colors.toolbarIcon,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          );
        }).toList(),
      ),
    );
  }
}
