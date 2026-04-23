import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'keyboard_theme.dart';

/// Single Samsung-style key.
/// - Rounded rectangle (radius 10)
/// - White bg with bottom shadow (letter keys)
/// - Gray bg (special keys)
/// - 80ms press darkening
/// - Floating popup bubble above key on press
class KeyWidget extends StatefulWidget {
  final String label;
  final Widget? icon;
  final bool isSpecial;       // gray background
  final Color? overrideBg;    // e.g. blue for Enter
  final Color? overrideText;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final bool showPopup;
  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  const KeyWidget({
    super.key,
    this.label = '',
    this.icon,
    this.isSpecial = false,
    this.overrideBg,
    this.overrideText,
    this.height = 46,
    this.fontSize = 20,
    this.fontWeight = FontWeight.w400,
    this.showPopup = true,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  @override
  State<KeyWidget> createState() => _KeyWidgetState();
}

class _KeyWidgetState extends State<KeyWidget> {
  bool _pressed = false;
  OverlayEntry? _overlay;

  void _down(BuildContext ctx) {
    HapticFeedback.lightImpact();
    setState(() => _pressed = true);
    if (widget.showPopup && widget.label.length == 1) _showBubble(ctx);
  }

  void _up() {
    setState(() => _pressed = false);
    _removeBubble();
    widget.onTap?.call();
  }

  void _cancel() {
    setState(() => _pressed = false);
    _removeBubble();
  }

  void _showBubble(BuildContext ctx) {
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos  = box.localToGlobal(Offset.zero);
    final size = box.size;
    final t    = KbTheme.of(ctx);

    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        left: pos.dx + size.width / 2 - 26,
        top:  pos.dy - 52,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: t.letterKey,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: t.shadowColor, blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: t.keyText,
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(ctx).insert(_overlay!);
  }

  void _removeBubble() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _removeBubble();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = KbTheme.of(context);
    final baseBg = widget.overrideBg ??
        (widget.isSpecial ? t.specialKey : t.letterKey);
    final bg = _pressed ? Color.lerp(baseBg, Colors.black, 0.12)! : baseBg;
    final textColor = widget.overrideText ??
        (widget.overrideBg != null ? Colors.white : t.keyText);

    return GestureDetector(
      onTapDown:       (_) => _down(context),
      onTapUp:         (_) => _up(),
      onTapCancel:     ()  => _cancel(),
      onLongPress:     widget.onLongPressStart,
      onLongPressEnd:  widget.onLongPressEnd != null ? (_) => widget.onLongPressEnd!() : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: widget.height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            // Bottom shadow — the defining Samsung key look
            BoxShadow(
              color: t.shadowColor,
              offset: const Offset(0, 1),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: widget.icon ??
            Text(
              widget.label,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: widget.fontWeight,
                color: textColor,
                height: 1.0,
              ),
            ),
      ),
    );
  }
}
