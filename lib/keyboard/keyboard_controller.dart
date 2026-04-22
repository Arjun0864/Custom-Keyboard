import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// ShiftState represents the current state of the shift key
enum ShiftState {
  off,      // Shift is off, lowercase
  once,     // Shift is on for next character only
  capsLock, // Caps lock is on, uppercase until toggled off
}

/// KeyboardLayout represents the current keyboard layout
enum KeyboardLayout {
  letters, // Standard QWERTY letters
  numbers, // Number pad layout
  symbols, // Symbols layout
}

/// KeyboardController manages the state and behavior of the keyboard
///
/// Responsibilities:
/// - Manage text input buffer
/// - Handle shift state (off/once/caps lock)
/// - Handle layout switching
/// - Process character input and special keys
/// - Auto-capitalize after sentence endings
/// - Double-space to add period
/// - Send text to Android IME via MethodChannel
class KeyboardController extends ChangeNotifier {
  // Platform channel for communication with Android IME
  static const platform =
      MethodChannel('com.flutterboard/keyboard');

  // Text buffer - accumulates input before sending to IME
  String _textBuffer = '';

  // Shift state
  ShiftState _shiftState = ShiftState.off;

  // Current keyboard layout
  KeyboardLayout _currentLayout = KeyboardLayout.letters;

  // Tracks the last character entered (for auto-capitalize detection)
  String? _lastCharacter;

  // Tracks consecutive spaces (for double-space period feature)
  int _consecutiveSpaces = 0;

  // Whether to capitalize the next letter
  bool _shouldCapitalizeNext = true;

  /// Getters
  String get textBuffer => _textBuffer;
  ShiftState get shiftState => _shiftState;
  KeyboardLayout get currentLayout => _currentLayout;
  bool get isShiftActive =>
      _shiftState == ShiftState.once || _shiftState == ShiftState.capsLock;
  bool get isCapsLock => _shiftState == ShiftState.capsLock;

  KeyboardController() {
    _shouldCapitalizeNext = true;
  }

  /// Insert a character into the text buffer
  ///
  /// - Applies shift if active
  /// - Auto-capitalizes after sentence endings
  /// - Sends to IME via MethodChannel
  /// - Handles shift state transitions
  Future<void> insertCharacter(String char) async {
    if (char.isEmpty) return;

    // Apply shift transformation if needed
    String finalChar = char;
    if (isShiftActive && char.length == 1) {
      finalChar = char.toUpperCase();
    } else if (_shouldCapitalizeNext && char.length == 1) {
      finalChar = char.toUpperCase();
      _shouldCapitalizeNext = false;
    }

    // Add to text buffer
    _textBuffer += finalChar;
    _lastCharacter = finalChar;
    _consecutiveSpaces = 0;

    // Send to IME
    await _sendToIME(finalChar);

    // Handle shift state transition
    if (_shiftState == ShiftState.once) {
      _shiftState = ShiftState.off;
    }

    notifyListeners();
  }

  /// Handle space key press
  ///
  /// - Double-space converts to period + space
  /// - Single space is sent to IME
  /// - Resets consecutive space counter after a non-space character
  Future<void> handleSpace() async {
    _consecutiveSpaces++;

    if (_consecutiveSpaces == 2) {
      // Double space: add period and space
      await deleteCharacter(); // Remove the first space we just added
      _textBuffer += '. ';
      _lastCharacter = ' ';
      _consecutiveSpaces = 0;
      _shouldCapitalizeNext = true;

      // Send period and space to IME
      await _sendToIME('.');
      await _sendToIME(' ');
    } else {
      // Single space
      _textBuffer += ' ';
      _lastCharacter = ' ';
      await _sendToIME(' ');
    }

    notifyListeners();
  }

  /// Handle backspace key
  ///
  /// - Deletes the last character from buffer
  /// - Sends backspace to IME
  /// - Updates auto-capitalize state
  Future<void> handleBackspace() async {
    if (_textBuffer.isEmpty) return;

    // Remove last character
    _textBuffer = _textBuffer.substring(0, _textBuffer.length - 1);

    // Update last character for context
    _lastCharacter = _textBuffer.isNotEmpty ? _textBuffer[_textBuffer.length - 1] : null;

    // Reset consecutive spaces
    _consecutiveSpaces = 0;

    // Check if we should capitalize the next character (after sentence end)
    _updateAutoCapitalize();

    // Send backspace to IME
    await _deleteFromIME();

    notifyListeners();
  }

  /// Delete a specific character count from the buffer
  ///
  /// Used internally for double-space period handling
  Future<void> deleteCharacter({int count = 1}) async {
    if (_textBuffer.length < count) {
      _textBuffer = '';
    } else {
      _textBuffer = _textBuffer.substring(0, _textBuffer.length - count);
    }

    _lastCharacter = _textBuffer.isNotEmpty ? _textBuffer[_textBuffer.length - 1] : null;
    _consecutiveSpaces = 0;
    _updateAutoCapitalize();

    // Send delete to IME
    for (int i = 0; i < count; i++) {
      await _deleteFromIME();
    }

    notifyListeners();
  }

  /// Handle enter/return key
  ///
  /// - Sends newline to IME
  /// - Resets consecutive spaces
  /// - Enables auto-capitalize for next character
  Future<void> handleEnter() async {
    _textBuffer += '\n';
    _lastCharacter = '\n';
    _consecutiveSpaces = 0;
    _shouldCapitalizeNext = true;

    // Send enter to IME
    await _sendToIME('\n');

    notifyListeners();
  }

  /// Toggle shift state
  ///
  /// - Off → Once (capitalize next char)
  /// - Once → Off
  /// - Off → CapsLock (if rapid double-press possible)
  void toggleShift() {
    if (_shiftState == ShiftState.off) {
      _shiftState = ShiftState.once;
    } else if (_shiftState == ShiftState.once) {
      _shiftState = ShiftState.capsLock;
    } else if (_shiftState == ShiftState.capsLock) {
      _shiftState = ShiftState.off;
    }

    notifyListeners();
  }

  /// Toggle caps lock state
  ///
  /// - Off ↔ CapsLock
  void toggleCapsLock() {
    if (_shiftState == ShiftState.capsLock) {
      _shiftState = ShiftState.off;
    } else {
      _shiftState = ShiftState.capsLock;
    }

    notifyListeners();
  }

  /// Switch to a different keyboard layout
  ///
  /// - letters: QWERTY layout
  /// - numbers: Number pad
  /// - symbols: Symbol layout
  void switchLayout(KeyboardLayout layout) {
    _currentLayout = layout;
    notifyListeners();
  }

  /// Toggle between letters and numbers layout
  void toggleNumbersLayout() {
    if (_currentLayout == KeyboardLayout.letters) {
      switchLayout(KeyboardLayout.numbers);
    } else {
      switchLayout(KeyboardLayout.letters);
    }
  }

  /// Clear the entire text buffer
  ///
  /// Used when starting fresh or resetting state
  Future<void> clearBuffer() async {
    _textBuffer = '';
    _lastCharacter = null;
    _consecutiveSpaces = 0;
    _shouldCapitalizeNext = true;
    _shiftState = ShiftState.off;

    notifyListeners();
  }

  /// Update auto-capitalize state based on last characters
  ///
  /// - Capitalizes after: . ! ?
  /// - Capitalizes at start of text
  void _updateAutoCapitalize() {
    if (_textBuffer.isEmpty) {
      _shouldCapitalizeNext = true;
      return;
    }

    // Get last non-space character
    int lastNonSpaceIndex = _textBuffer.length - 1;
    while (lastNonSpaceIndex >= 0 &&
        _textBuffer[lastNonSpaceIndex].contains(RegExp(r'\s'))) {
      lastNonSpaceIndex--;
    }

    if (lastNonSpaceIndex < 0) {
      _shouldCapitalizeNext = true;
      return;
    }

    final lastNonSpaceChar = _textBuffer[lastNonSpaceIndex];
    _shouldCapitalizeNext = lastNonSpaceChar.contains(RegExp(r'[.!?]'));
  }

  /// Send character to Android IME via MethodChannel
  ///
  /// Communicates with the native Android InputMethodService
  /// to actually commit text to the focused text field
  Future<void> _sendToIME(String character) async {
    try {
      await platform.invokeMethod('commitText', {
        'text': character,
      });
    } catch (e) {
      debugPrint('Error sending to IME: $e');
    }
  }

  /// Delete a character from the Android IME
  Future<void> _deleteFromIME() async {
    try {
      await platform.invokeMethod('deleteBackward');
    } catch (e) {
      debugPrint('Error deleting from IME: $e');
    }
  }

  /// Send the entire text buffer to IME
  ///
  /// Useful for syncing state or batch operations
  Future<void> sendAllToIME() async {
    try {
      await platform.invokeMethod('insertText', {
        'text': _textBuffer,
      });
    } catch (e) {
      debugPrint('Error sending buffer to IME: $e');
    }
  }

  /// Get surrounding text from the active text field
  ///
  /// Used for context-aware features like auto-correct
  /// or suggestion based on surrounding text
  Future<String?> getSurroundingText({
    int beforeLength = 50,
    int afterLength = 50,
  }) async {
    try {
      final result = await platform.invokeMethod('getSurroundingText', {
        'beforeLength': beforeLength,
        'afterLength': afterLength,
      });
      return result as String?;
    } catch (e) {
      debugPrint('Error getting surrounding text: $e');
      return null;
    }
  }

  /// Commit text directly to IME
  ///
  /// Bypasses the buffer and sends text directly
  /// Used for special characters or auto-corrections
  Future<void> commitText(String text) async {
    try {
      await platform.invokeMethod('commitText', {
        'text': text,
      });
    } catch (e) {
      debugPrint('Error committing text: $e');
    }
  }

  /// Get diagnostic information
  ///
  /// Useful for debugging and testing
  Map<String, dynamic> getDiagnostics() {
    return {
      'textBuffer': _textBuffer,
      'bufferlength': _textBuffer.length,
      'shiftState': _shiftState.toString(),
      'currentLayout': _currentLayout.toString(),
      'isShiftActive': isShiftActive,
      'isCapsLock': isCapsLock,
      'shouldCapitalizeNext': _shouldCapitalizeNext,
      'lastCharacter': _lastCharacter,
      'consecutiveSpaces': _consecutiveSpaces,
    };
  }


}
