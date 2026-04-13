import 'package:flutter/material.dart';
import 'keyboard_key.dart';

class KeyboardRow extends StatelessWidget {
  final List<KeyboardKey> keys;

  const KeyboardRow({super.key, required this.keys});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // Standard row height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: keys,
      ),
    );
  }
}