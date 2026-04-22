import 'package:flutter/material.dart';
import 'keyboard_theme.dart';
import 'keyboard_controller.dart';

/// Samsung-style clipboard panel — last 5 items as cards.
class ClipboardPanel extends StatefulWidget {
  final KeyboardController controller;

  const ClipboardPanel({super.key, required this.controller});

  @override
  State<ClipboardPanel> createState() => _ClipboardPanelState();
}

class _ClipboardPanelState extends State<ClipboardPanel> {
  // In a real IME this would be populated from ClipboardDatabase
  final List<String> _items = [];

  @override
  Widget build(BuildContext context) {
    final colors = KbColors.of(context);

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.content_paste, size: 48, color: colors.toolbarIcon),
            const SizedBox(height: 12),
            Text(
              'Clipboard is empty',
              style: TextStyle(fontSize: 14, color: colors.toolbarIcon),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _items.take(5).length,
      itemBuilder: (_, i) {
        final item = _items[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: colors.letterKeyBg,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => widget.controller.insertCharacter(item),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: colors.keyText),
                      ),
                    ),
                    Icon(Icons.push_pin_outlined, size: 18, color: colors.toolbarIcon),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
