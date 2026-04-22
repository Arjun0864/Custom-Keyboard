import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'key_widget.dart';
import 'keyboard_theme.dart';
import 'keyboard_controller.dart';

/// Full Samsung-style QWERTY panel.
/// Shift: OFF → ONCE → CAPS → OFF
/// Backspace: hold = continuous accelerating delete
class QwertyPanel extends StatefulWidget {
  final KeyboardController controller;
  final VoidCallback onSwitchToNumbers;
  final VoidCallback onSwitchToEmoji;

  const QwertyPanel({
    super.key,
    required this.controller,
    required this.onSwitchToNumbers,
    required this.onSwitchToEmoji,
  });

  @override
  State<QwertyPanel> createState() => _QwertyPanelState();
}

class _QwertyPanelState extends State<QwertyPanel> {
  static const _row1 = ['q','w','e','r','t','y','u','i','o','p'];
  static const _row2 = ['a','s','d','f','g','h','j','k','l'];
  static const _row3 = ['z','x','c','v','b','n','m'];

  Timer? _backspaceTimer;

  @override
  void dispose() {
    _backspaceTimer?.cancel();
    super.dispose();
  }

  void _startBackspace() {
    widget.controller.handleBackspace();
    _backspaceTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      widget.controller.handleBackspace();
    });
  }

  void _stopBackspace() {
    _backspaceTimer?.cancel();
    _backspaceTimer = null;
  }

  void _tapKey(String k) {
    HapticFeedback.lightImpact();
    widget.controller.insertCharacter(k);
  }

  @override
  Widget build(BuildContext context) {
    final colors = KbColors.of(context);
    final ctrl   = widget.controller;

    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) {
        final isShift = ctrl.isShiftActive;
        final isCaps  = ctrl.isCapsLock;

        return Padding(
          padding: const EdgeInsets.fromLTRB(3, 6, 3, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1 — Q W E R T Y U I O P
              _buildRow(
                _row1.map((k) => isShift ? k.toUpperCase() : k).toList(),
                colors,
                onTap: (k) => _tapKey(k),
              ),
              const SizedBox(height: 3),
              // Row 2 — A S D F G H J K L (Samsung offset)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _buildRow(
                  _row2.map((k) => isShift ? k.toUpperCase() : k).toList(),
                  colors,
                  onTap: (k) => _tapKey(k),
                ),
              ),
              const SizedBox(height: 3),
              // Row 3 — SHIFT + Z..M + BACKSPACE
              _buildRow3(colors, isShift, isCaps),
              const SizedBox(height: 3),
              // Row 4 — ?123 | emoji | SPACE | ENTER
              _buildBottomRow(colors),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(List<String> keys, KbColors colors,
      {required ValueChanged<String> onTap}) {
    return Row(
      children: keys.map((k) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: KeyWidget(
              label: k,
              height: 52,
              onTap: () => onTap(k),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRow3(KbColors colors, bool isShift, bool isCaps) {
    final ctrl = widget.controller;
    return Row(
      children: [
        // SHIFT key — 1.5x
        SizedBox(
          width: _shiftWidth(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: KeyWidget(
              isSpecial: true,
              height: 52,
              showPopup: false,
              onTap: ctrl.toggleShift,
              child: Icon(
                isCaps
                    ? Icons.keyboard_capslock
                    : isShift
                        ? Icons.arrow_upward
                        : Icons.arrow_upward_outlined,
                size: 20,
                color: (isShift || isCaps)
                    ? colors.accentBlue
                    : colors.keyText,
              ),
            ),
          ),
        ),
        // Z X C V B N M
        Expanded(
          child: Row(
            children: _row3.map((k) {
              final display = isShift ? k.toUpperCase() : k;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: KeyWidget(
                    label: display,
                    height: 52,
                    onTap: () => _tapKey(k),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // BACKSPACE — 1.5x
        SizedBox(
          width: _shiftWidth(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: KeyWidget(
              isSpecial: true,
              height: 52,
              showPopup: false,
              onTap: ctrl.handleBackspace,
              onLongPress: _startBackspace,
              onLongPressEnd: _stopBackspace,
              child: Icon(Icons.backspace_outlined, size: 20, color: colors.keyText),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRow(KbColors colors) {
    final ctrl = widget.controller;
    return Row(
      children: [
        // ?123 — 1.5x
        SizedBox(
          width: _shiftWidth(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: KeyWidget(
              isSpecial: true,
              height: 52,
              showPopup: false,
              onTap: widget.onSwitchToNumbers,
              child: Text('?123',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.keyText)),
            ),
          ),
        ),
        // Emoji
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: SizedBox(
            width: 40,
            child: KeyWidget(
              isSpecial: true,
              height: 52,
              showPopup: false,
              onTap: widget.onSwitchToEmoji,
              child: const Text('😊', style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
        // SPACE — flex 4
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: KeyWidget(
              isSpecial: false,
              height: 52,
              showPopup: false,
              onTap: ctrl.handleSpace,
              child: Text(
                'AB Keyboard',
                style: TextStyle(fontSize: 11, color: colors.keyText.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ),
        // ENTER
        SizedBox(
          width: _shiftWidth(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: KeyWidget(
              bgColor: colors.accentBlue,
              height: 52,
              showPopup: false,
              onTap: ctrl.handleEnter,
              child: const Icon(Icons.keyboard_return, size: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  double _shiftWidth(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    // 1.5x of a standard key width (10 keys in row1 + gaps)
    final keyW = (screenW - 6 - 18) / 10;
    return keyW * 1.5;
  }
}
