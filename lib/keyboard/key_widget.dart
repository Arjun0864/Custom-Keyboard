import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'keyboard_theme.dart';

/// A single Samsung-style key with press animation, shadow, and popup bubble.
class KeyWidget extends StatefulWidget {
  final String label;
  final Widget? child;          // override label with icon
  final Color? bgColor;         // null → letterKeyBg
  final bool isSpecial;         // uses specialKeyBg
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onLongPressEnd;
  final bool showPopup;         // show floating bubble on press

  const KeyWidget({
    super.key,
    this.label = '',
    this.child,
    this.bgColor,
    this.isSpecial = false,
    this.height = 52,
    this.onTap,
    this.onLongPress,
    this.onLongPressEnd,
    this.showPopup = true,
  });

  @override
  State<KeyWidget> createState() => _KeyWidgetState();
}

class _KeyWidgetState extends State<KeyWidget> {
  bool _pressed = false;
  OverlayEntry? _popup;

  void _showPopup(BuildContext ctx) {
    if (!widget.showPopup || widget.label.isEmpty || widget.label.length > 1) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;
    final colors = KbColors.of(ctx);

    _popup = OverlayEntry(
      builder: (_) => Positioned(
        left: pos.dx + size.width / 2 - 28,
        top: pos.dy - 56,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.letterKeyBg,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.keyText,
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(ctx).insert(_popup!);
  }

  void _removePopup() {
    _popup?.remove();
    _popup = null;
  }

  @override
  void dispose() {
    _removePopup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = KbColors.of(context);
    final baseBg = widget.bgColor ??
        (widget.isSpecial ? colors.specialKeyBg : colors.letterKeyBg);
    // SAMSUNG-STYLE: darken 15% on press
    final bg = _pressed
        ? Color.lerp(baseBg, Colors.black, 0.15)!
        : baseBg;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
        _showPopup(context);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _removePopup();
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _removePopup();
      },
      onLongPress: widget.onLongPress,
      onLongPressEnd: widget.onLongPressEnd != null
          ? (_) => widget.onLongPressEnd!()
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: widget.height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              offset: const Offset(0, 1),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: widget.child ??
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
                color: colors.keyText,
              ),
            ),
      ),
    );
  }
}
