import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'keyboard_state.dart';
import '../services/keyboard_service.dart';

class KeyboardKey extends ConsumerWidget {
  final String label;
  final dynamic value;
  final double widthRatio;
  final bool isSpecial;

  const KeyboardKey({
    super.key,
    required this.label,
    required this.value,
    this.widthRatio = 1.0,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(keyboardStateProvider);
    final keyboardService = ref.watch(keyboardChannelServiceProvider);
    final theme = state.currentTheme;

    return Expanded(
      flex: (widthRatio * 10).toInt(),
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          ref.read(keyboardStateProvider.notifier).onKeyTap(value);
        },
        onTap: () => _handleKeyPress(keyboardService, ref),
        onLongPress: () {
          ref.read(keyboardStateProvider.notifier).onKeyLongPress(value);
        },
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isSpecial ? theme.specialKeyColor : theme.keyColor,
            borderRadius: BorderRadius.circular(theme.keyBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 1),
                blurRadius: 1,
              )
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: theme.keyTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleKeyPress(KeyboardService keyboardService, WidgetRef ref) {
    final valueStr = value.toString();

    switch (valueStr) {
      case 'BACKSPACE':
        keyboardService.deleteBackward();
        break;
      case 'SPACE':
        keyboardService.commitText(' ');
        break;
      case 'ENTER':
        keyboardService.commitText('\n');
        break;
      case 'SHIFT':
        ref.read(keyboardStateProvider.notifier).toggleShift();
        break;
      case '123':
        ref.read(keyboardStateProvider.notifier).setLayer(KeyboardLayer.symbols1);
        break;
      case 'ABC':
        ref.read(keyboardStateProvider.notifier).setLayer(KeyboardLayer.main);
        break;
      case 'LANG':
        // Switch language
        break;
      default:
        keyboardService.commitText(valueStr);
        break;
    }
  }
}
