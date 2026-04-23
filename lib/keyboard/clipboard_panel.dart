import 'package:flutter/material.dart';
import 'keyboard_theme.dart';
import 'keyboard_controller.dart';

class ClipboardPanel extends StatelessWidget {
  final KeyboardController controller;
  const ClipboardPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final t = KbTheme.of(context);
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.content_paste, size: 44, color: t.toolbarIcon),
      const SizedBox(height: 10),
      Text('Clipboard is empty',
        style: TextStyle(fontSize: 14, color: t.toolbarIcon)),
    ]));
  }
}
