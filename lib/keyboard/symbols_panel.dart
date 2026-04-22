import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'key_widget.dart';
import 'keyboard_theme.dart';
import 'keyboard_controller.dart';

/// Numbers + Symbols panel (Samsung ?123 / #+= layout).
class SymbolsPanel extends StatefulWidget {
  final KeyboardController controller;
  final VoidCallback onSwitchToQwerty;
  final VoidCallback onSwitchToEmoji;

  const SymbolsPanel({
    super.key,
    required this.controller,
    required this.onSwitchToQwerty,
    required this.onSwitchToEmoji,
  });

  @override
  State<SymbolsPanel> createState() => _SymbolsPanelState();
}

class _SymbolsPanelState extends State<SymbolsPanel> {
  bool _showMore = false; // false = numbers, true = symbols

  static const _numRow1 = ['1','2','3','4','5','6','7','8','9','0'];
  static const _numRow2 = ['!','@','#','\$','%','^','&','*','(',')'];
  static const _numRow3 = ['-','/',':',';','₹','&','@','"'];

  static const _symRow1 = ['~','`','|','•','√','π','÷','×','¶','∆'];
  static const _symRow2 = ['£','¢','€','¥','^','°','=','{','}','\\'];
  static const _symRow3 = ['_','<','>','[',']','!','?','\''];

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

  void _tap(String k) {
    HapticFeedback.lightImpact();
    widget.controller.insertCharacter(k);
  }

  @override
  Widget build(BuildContext context) {
    final colors = KbColors.of(context);
    final r1 = _showMore ? _symRow1 : _numRow1;
    final r2 = _showMore ? _symRow2 : _numRow2;
    final r3 = _showMore ? _symRow3 : _numRow3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(3, 6, 3, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(r1, colors),
          const SizedBox(height: 3),
          _buildRow(r2, colors),
          const SizedBox(height: 3),
          _buildRow3(r3, colors),
          const SizedBox(height: 3),
          _buildBottomRow(colors),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys, KbColors colors) {
    return Row(
      children: keys.map((k) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: KeyWidget(label: k, height: 52, onTap: () => _tap(k)),
        ),
      )).toList(),
    );
  }

  Widget _buildRow3(List<String> keys, KbColors colors) {
    return Row(
      children: [
        // Toggle more/less symbols
        SizedBox(
          width: _specialW(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: KeyWidget(
              isSpecial: true,
              height: 52,
              showPopup: false,
              onTap: () => setState(() => _showMore = !_showMore),
              child: Text(
                _showMore ? '?123' : '#+= ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.keyText),
              ),
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: keys.map((k) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: KeyWidget(label: k, height: 52, onTap: () => _tap(k)),
              ),
            )).toList(),
          ),
        ),
        // Backspace
        SizedBox(
          width: _specialW(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: KeyWidget(
              isSpecial: true,
              height: 52,
              showPopup: false,
              onTap: widget.controller.handleBackspace,
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
    return Row(
      children: [
        SizedBox(
          width: _specialW(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: KeyWidget(
              isSpecial: true,
              height: 52,
              showPopup: false,
              onTap: widget.onSwitchToQwerty,
              child: Text('ABC',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.keyText)),
            ),
          ),
        ),
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
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: KeyWidget(
              height: 52,
              showPopup: false,
              onTap: widget.controller.handleSpace,
              child: Text('AB Keyboard',
                  style: TextStyle(fontSize: 11, color: colors.keyText.withValues(alpha: 0.5))),
            ),
          ),
        ),
        SizedBox(
          width: _specialW(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: KeyWidget(
              bgColor: colors.accentBlue,
              height: 52,
              showPopup: false,
              onTap: widget.controller.handleEnter,
              child: const Icon(Icons.keyboard_return, size: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  double _specialW(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return (screenW - 6 - 18) / 10 * 1.5;
  }
}
