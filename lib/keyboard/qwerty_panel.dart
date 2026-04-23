import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'key_widget.dart';
import 'keyboard_theme.dart';
import 'keyboard_controller.dart';

class QwertyPanel extends StatefulWidget {
  final KeyboardController controller;
  final VoidCallback onNumbers;
  final VoidCallback onEmoji;

  const QwertyPanel({
    super.key,
    required this.controller,
    required this.onNumbers,
    required this.onEmoji,
  });

  @override
  State<QwertyPanel> createState() => _QwertyPanelState();
}

class _QwertyPanelState extends State<QwertyPanel> {
  static const _row1 = ['q','w','e','r','t','y','u','i','o','p'];
  static const _row2 = ['a','s','d','f','g','h','j','k','l'];
  static const _row3 = ['z','x','c','v','b','n','m'];

  Timer? _bsTimer;

  @override
  void dispose() { _bsTimer?.cancel(); super.dispose(); }

  void _startBs() {
    widget.controller.handleBackspace();
    _bsTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      widget.controller.handleBackspace();
    });
  }
  void _stopBs() { _bsTimer?.cancel(); _bsTimer = null; }
  void _tap(String k) {
    HapticFeedback.lightImpact();
    widget.controller.insertCharacter(k);
  }

  @override
  Widget build(BuildContext context) {
    final t = KbTheme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (ctx, _) {
        final shift = widget.controller.isShiftActive;
        final caps  = widget.controller.isCapsLock;

        return LayoutBuilder(builder: (ctx, bc) {
          final W = bc.maxWidth;
          const hEdge = 4.0;
          const gap   = 5.0;
          // 10 keys in row1, 9 gaps, 2 edges
          final keyW = (W - hEdge * 2 - gap * 9) / 10;
          const keyH  = 44.0;
          const rowGap = 8.0;

          return Padding(
            padding: const EdgeInsets.fromLTRB(hEdge, 6, hEdge, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Row 1: Q-P ──────────────────────────────────────────────
                _letterRow(
                  _row1.map((k) => shift ? k.toUpperCase() : k).toList(),
                  keyW, keyH, gap,
                ),
                const SizedBox(height: rowGap),

                // ── Row 2: A-L (Samsung offset) ─────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: keyW * 0.5 + gap * 0.5),
                  child: _letterRow(
                    _row2.map((k) => shift ? k.toUpperCase() : k).toList(),
                    keyW, keyH, gap,
                  ),
                ),
                const SizedBox(height: rowGap),

                // ── Row 3: Shift + Z-M + Backspace ──────────────────────────
                _row3Widget(keyW, keyH, gap, t, shift, caps),
                const SizedBox(height: rowGap),

                // ── Row 4: !#1 , SPACE . Next ───────────────────────────────
                _bottomRow(keyW, keyH, gap, t),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _letterRow(List<String> keys, double kw, double kh, double gap) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < keys.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          SizedBox(
            width: kw, height: kh,
            child: KeyWidget(
              label: keys[i],
              height: kh,
              onTap: () => _tap(keys[i]),
            ),
          ),
        ],
      ],
    );
  }

  Widget _row3Widget(double kw, double kh, double gap, KbTheme t,
      bool shift, bool caps) {
    final sw = kw * 1.5;
    final ctrl = widget.controller;
    return Row(
      children: [
        SizedBox(
          width: sw, height: kh,
          child: KeyWidget(
            isSpecial: true, height: kh, showPopup: false,
            onTap: ctrl.toggleShift,
            icon: Icon(
              caps ? Icons.keyboard_capslock
                   : shift ? Icons.arrow_upward
                           : Icons.arrow_upward_outlined,
              size: 20,
              color: (shift || caps) ? const Color(0xFF007AFF) : t.keyText,
            ),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Row(
            children: [
              for (int i = 0; i < _row3.length; i++) ...[
                if (i > 0) SizedBox(width: gap),
                Expanded(
                  child: SizedBox(
                    height: kh,
                    child: KeyWidget(
                      label: shift ? _row3[i].toUpperCase() : _row3[i],
                      height: kh,
                      onTap: () => _tap(_row3[i]),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: gap),
        SizedBox(
          width: sw, height: kh,
          child: KeyWidget(
            isSpecial: true, height: kh, showPopup: false,
            onTap: ctrl.handleBackspace,
            onLongPressStart: _startBs,
            onLongPressEnd: _stopBs,
            icon: Icon(Icons.backspace_outlined, size: 20, color: t.keyText),
          ),
        ),
      ],
    );
  }

  Widget _bottomRow(double kw, double kh, double gap, KbTheme t) {
    final sw   = kw * 1.5;
    final ctrl = widget.controller;
    return Row(
      children: [
        SizedBox(
          width: sw, height: kh,
          child: KeyWidget(
            label: '!#1', isSpecial: true, height: kh,
            fontSize: 13, fontWeight: FontWeight.w600,
            showPopup: false, onTap: widget.onNumbers,
          ),
        ),
        SizedBox(width: gap),
        SizedBox(
          width: kw, height: kh,
          child: KeyWidget(
            label: ',', isSpecial: true, height: kh,
            fontSize: 18, showPopup: false,
            onTap: () => _tap(','),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: SizedBox(
            height: kh,
            child: KeyWidget(
              height: kh, showPopup: false,
              onTap: ctrl.handleSpace,
              icon: Text(
                'English (US)',
                style: TextStyle(fontSize: 12, color: t.spaceText),
              ),
            ),
          ),
        ),
        SizedBox(width: gap),
        SizedBox(
          width: kw, height: kh,
          child: KeyWidget(
            label: '.', isSpecial: true, height: kh,
            fontSize: 18, showPopup: false,
            onTap: () => _tap('.'),
          ),
        ),
        SizedBox(width: gap),
        SizedBox(
          width: sw, height: kh,
          child: KeyWidget(
            label: 'Next',
            overrideBg: t.enterBg,
            overrideText: t.enterText,
            height: kh, fontSize: 14,
            fontWeight: FontWeight.w600,
            showPopup: false,
            onTap: ctrl.handleEnter,
          ),
        ),
      ],
    );
  }
}
