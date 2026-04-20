import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// KeyType enum defines different types of keys on the keyboard
enum KeyType {
  character,  // Regular letter/number
  backspace,  // Delete key
  enter,      // Return/Enter key
  space,      // Space key
  shift,      // Shift/Uppercase key
  tab,        // Tab key
  symbol,     // Symbol toggle key
  custom,     // Custom action key
}

/// A single customizable keyboard key button widget
///
/// Supports:
/// - Different key types (character, backspace, enter, space, shift, etc.)
/// - Long press for symbol input
/// - Ripple effect on tap
/// - Customizable size, color, border radius, and font size
/// - Visual feedback for pressed state
/// - Haptic feedback on press
class KeyButton extends StatefulWidget {
  /// The character or label displayed on the key
  final String label;

  /// Type of key (character, backspace, enter, space, shift, etc.)
  final KeyType keyType;

  /// Width of the button in logical pixels (default: 40)
  final double width;

  /// Height of the button in logical pixels (default: 50)
  final double height;

  /// Background color of the button
  final Color? backgroundColor;

  /// Text color of the label
  final Color? textColor;

  /// Border radius for rounded corners
  final double borderRadius;

  /// Font size of the label text
  final double fontSize;

  /// Font weight of the label text
  final FontWeight fontWeight;

  /// Callback when the key is pressed
  final VoidCallback? onPressed;

  /// Callback when the key is long pressed (for symbols)
  final VoidCallback? onLongPress;

  /// Callback with the character value
  final Function(String)? onCharacterInput;

  /// Icon to display instead of text label (e.g., for backspace)
  final IconData? icon;

  /// Icon size if using icon
  final double iconSize;

  /// Whether the key should show pressed visual state
  final bool isPressed;

  /// Whether shift is currently active
  final bool isShiftActive;

  /// Whether the keyboard is in symbol mode
  final bool isSymbolMode;

  const KeyButton({
    Key? key,
    required this.label,
    this.keyType = KeyType.character,
    this.width = 40,
    this.height = 50,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 4,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w500,
    this.onPressed,
    this.onLongPress,
    this.onCharacterInput,
    this.icon,
    this.iconSize = 24,
    this.isPressed = false,
    this.isShiftActive = false,
    this.isSymbolMode = false,
  }) : super(key: key);

  @override
  State<KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<KeyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get the display text based on shift state
  String _getDisplayText() {
    if (widget.keyType == KeyType.character) {
      // If shift is active, show uppercase
      if (widget.isShiftActive && widget.label.length == 1) {
        return widget.label.toUpperCase();
      }
    }
    return widget.label;
  }

  /// Get background color based on key type and state
  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }

    // Default colors based on key type
    if (widget.isPressed) {
      return Colors.grey[600]!;
    }

    switch (widget.keyType) {
      case KeyType.backspace:
      case KeyType.enter:
      case KeyType.shift:
      case KeyType.symbol:
        return Colors.grey[700]!; // Darker for action keys
      case KeyType.space:
        return Colors.grey[200]!;
      default:
        return Colors.grey[300]!;
    }
  }

  /// Get text color based on background and state
  Color _getTextColor() {
    if (widget.textColor != null) {
      return widget.textColor!;
    }

    switch (widget.keyType) {
      case KeyType.backspace:
      case KeyType.enter:
      case KeyType.shift:
      case KeyType.symbol:
        return Colors.white;
      default:
        return Colors.black87;
    }
  }

  /// Handle key press down
  void _onKeyDown() {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  /// Handle key press up
  void _onKeyUp() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  /// Handle tap action
  void _handleTap() {
    _onKeyUp();

    // Trigger haptic feedback
    HapticFeedback.lightImpact();

    // Call appropriate callback based on key type
    if (widget.keyType == KeyType.character) {
      final displayChar = widget.isShiftActive
          ? widget.label.toUpperCase()
          : widget.label.toLowerCase();
      widget.onCharacterInput?.call(displayChar);
    }

    widget.onPressed?.call();
  }

  /// Handle long press action
  void _handleLongPress() {
    _onKeyUp();
    HapticFeedback.mediumImpact();
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _onKeyDown(),
        onTapUp: (_) => _handleTap(),
        onTapCancel: _onKeyUp,
        onLongPress: _handleLongPress,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleTap,
            onLongPress: _handleLongPress,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            splashColor: Colors.grey[400]?.withValues(alpha: 0.5),
            highlightColor: Colors.grey[400]?.withValues(alpha: 0.3),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1,
                ),
                boxShadow: [
                  if (!_isPressed)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Center(
                child: _buildKeyContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the content of the key button (icon or text)
  Widget _buildKeyContent() {
    // Display icon if provided
    if (widget.icon != null) {
      return Icon(
        widget.icon,
        size: widget.iconSize,
        color: _getTextColor(),
      );
    }

    // Display text label
    return Text(
      _getDisplayText(),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        color: _getTextColor(),
      ),
    );
  }
}
