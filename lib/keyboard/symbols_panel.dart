import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'key_widget.dart';
import 'keyboard_theme.dart';
import 'keyboard_controller.dart';

class SymbolsPanel extends StatefulWidget {
  final KeyboardController controller;
  final VoidCallback onQwerty;
  final VoidCallback onEmoji;

  const SymbolsPanel({
    super.key,
    required this.controller,
    required this.onQwerty,
    required this.onEmoji,
  });

  @override
  State<SymbolsPanel> createState() => _SymbolsPanelState();
}

class _SymbolsPanelState extends State<SymbolsPanel> {
  bool _more = false;
  Timer? _bsTimer;

  static const _n1 = ['1','2','3','4','5','6','7','8','9','0'];
  static const _n2 = ['!','@','#','\$','%','^','&','*','(',')'];
  static const _n3 = ['-','/',':',';','(',')','\$','&','@','"'];
  static const _s1 = ['~','`','|','•','√','π','÷','×','¶','∆'];
  static const _s2 = ['£','¢','€','₹','^','°','=','{','}','\\'];
  static const _s3 = ['_','<','>','[',']','!','?','\'','+','-'];

  @override
  void dispose() { _bsTimer?.cancel(); super.dispose(); }

  void _startBs() {
    widget.controller.handleBackspace();
    _bsTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      widget.controller.handleBackspace();
    });
  }
  void _stopBs() { _bsTimer?.cancel(); _bsTimer = null; }
  void _tap(String k) { HapticFeedback.lightImpact(); widget.controller.insertCharacter(k); }

  @override
  Widget build(BuildContext context) {
    final t  = KbTheme.of(context);
    final r1 = _more ? _s1 : _n1;
    final r2 = _more ? _s2 : _n2;
    final r3 = _more ? _s3 : _n3;

    return LayoutBuilder(builder: (ctx, bc) {
      final W = bc.maxWidth;
      const hEdge = 4.0;
      const gap   = 5.0;
      final keyW  = (W - hEdge * 2 - gap * 9) / 10;
      const keyH  = 44.0;
      const rowGap = 8.0;

      return Padding(
        padding: const EdgeInsets.fromLTRB(hEdge, 6, hEdge, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row(r1, keyW, keyH, gap),
            const SizedBox(height: rowGap),
            _row(r2, keyW, keyH, gap),
            const SizedBox(height: rowGap),
            _row3w(r3, keyW, keyH, gap, t),
            const SizedBox(height: rowGap),
            _bottomRow(keyW, keyH, gap, t),
          ],
        ),
      );
    });
  }

  Widget _row(List<String> keys, double kw, double kh, double gap) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < keys.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          SizedBox(width: kw, height: kh,
            child: KeyWidget(label: keys[i], height: kh, onTap: () => _tap(keys[i]))),
        ],
      ],
    );
  }

  Widget _row3w(List<String> keys, double kw, double kh, double gap, KbTheme t) {
    final sw = kw * 1.5;
    return Row(
      children: [
        SizedBox(width: sw, height: kh,
          child: KeyWidget(
            label: _more ? '?123' : '#+=',
            isSpecial: true, height: kh, fontSize: 12,
            fontWeight: FontWeight.w600, showPopup: false,
            onTap: () => setState(() => _more = !_more),
          )),
        SizedBox(width: gap),
        Expanded(child: Row(children: [
          for (int i = 0; i < keys.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Expanded(child: SizedBox(height: kh,
              child: KeyWidget(label: keys[i], height: kh, onTap: () => _tap(keys[i])))),
          ],
        ])),
        SizedBox(width: gap),
        SizedBox(width: sw, height: kh,
          child: KeyWidget(
            isSpecial: true, height: kh, showPopup: false,
            onTap: widget.controller.handleBackspace,
            onLongPressStart: _startBs, onLongPressEnd: _stopBs,
            icon: Icon(Icons.backspace_outlined, size: 20, color: t.keyText),
          )),
      ],
    );
  }

  Widget _bottomRow(double kw, double kh, double gap, KbTheme t) {
    final sw = kw * 1.5;
    return Row(
      children: [
        SizedBox(width: sw, height: kh,
          child: KeyWidget(label: 'ABC', isSpecial: true, height: kh,
            fontSize: 13, fontWeight: FontWeight.w600, showPopup: false,
            onTap: widget.onQwerty)),
        SizedBox(width: gap),
        SizedBox(width: kw, height: kh,
          child: KeyWidget(label: '😊', isSpecial: true, height: kh,
            fontSize: 18, showPopup: false, onTap: widget.onEmoji)),
        SizedBox(width: gap),
        Expanded(child: SizedBox(height: kh,
          child: KeyWidget(
            height: kh, showPopup: false,
            onTap: widget.controller.handleSpace,
            icon: Text('English (US)',
              style: TextStyle(fontSize: 12, color: t.spaceText)),
          ))),
        SizedBox(width: gap),
        SizedBox(width: sw, height: kh,
          child: KeyWidget(
            label: 'Next', overrideBg: t.enterBg, overrideText: t.enterText,
            height: kh, fontSize: 14, fontWeight: FontWeight.w600,
            showPopup: false, onTap: widget.controller.handleEnter)),
      ],
    );
  }
}
