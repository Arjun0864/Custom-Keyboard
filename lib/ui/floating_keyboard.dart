import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'keyboard_state.dart';
import 'keyboard_layout.dart';

class FloatingKeyboard extends ConsumerStatefulWidget {
  const FloatingKeyboard({super.key});

  @override
  ConsumerState<FloatingKeyboard> createState() => _FloatingKeyboardState();
}

class _FloatingKeyboardState extends ConsumerState<FloatingKeyboard> {
  Offset position = const Offset(50, 400);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(keyboardStateProvider);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
          });
        },
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: state.keyboardHeight,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: state.currentTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: KeyboardLayout(layer: state.layer),
          ),
        ),
      ),
    );
  }
}
