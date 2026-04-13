import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_constants.dart';

/// Riverpod provider for KeyboardService
final keyboardServiceProvider = Provider<KeyboardService>((ref) {
  return KeyboardService();
});

/// Legacy provider name for backwards compatibility
final keyboardChannelServiceProvider = Provider<KeyboardService>((ref) {
  return KeyboardService();
});

/// Riverpod provider for SettingsChannelService
final settingsChannelProvider = Provider<SettingsChannelService>((ref) {
  return SettingsChannelService();
});

/// Service for handling IME keyboard operations
class KeyboardService {
  static final KeyboardService _instance = KeyboardService._internal();

  factory KeyboardService() {
    return _instance;
  }

  KeyboardService._internal();

  late final MethodChannel _methodChannel = MethodChannel(AppConstants.methodChannel);
  late final EventChannel _eventChannel = EventChannel(AppConstants.eventChannel);
  late final MethodChannel _inputChannel = MethodChannel(AppConstants.inputChannel);

  Stream<Map<String, dynamic>>? _keyboardEventStream;

  /// Initialize keyboard service and set up listeners
  Future<void> initialize() async {
    try {
      // Test connection to IME service
      final result = await _methodChannel.invokeMethod<bool>('isKeyboardMode');
      debugPrint('Keyboard Mode: $result');
    } catch (e) {
      debugPrint('Error initializing keyboard service: $e');
    }
  }

  /// Get keyboard event stream
  Stream<Map<String, dynamic>> getKeyboardEventStream() {
    _keyboardEventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _keyboardEventStream!;
  }

  /// Alias for Riverpod compatibility
  Stream<Map<String, dynamic>> get events => getKeyboardEventStream();

  /// Listen to keyboard events
  void onKeyboardEvent(Function(Map<String, dynamic>) callback) {
    getKeyboardEventStream().listen(callback);
  }

  // ====== Text Operations ======

  /// Commit text to the input field
  Future<void> commitText(String text) async {
    try {
      await _methodChannel.invokeMethod('commitText', {'text': text});
    } on PlatformException catch (e) {
      debugPrint('Error committing text: ${e.message}');
    }
  }

  /// Delete backward (backspace)
  Future<void> deleteBackward() async {
    try {
      await _methodChannel.invokeMethod('deleteBackward');
    } on PlatformException catch (e) {
      debugPrint('Error deleting backward: ${e.message}');
    }
  }

  /// Delete forward
  Future<void> deleteForward() async {
    try {
      await _methodChannel.invokeMethod('deleteForward');
    } on PlatformException catch (e) {
      debugPrint('Error deleting forward: ${e.message}');
    }
  }

  /// Move cursor by offset
  Future<void> moveCursor(int offset) async {
    try {
      await _methodChannel.invokeMethod('moveCursor', {'offset': offset});
    } on PlatformException catch (e) {
      debugPrint('Error moving cursor: ${e.message}');
    }
  }

  /// Select all text
  Future<void> selectAll() async {
    try {
      await _methodChannel.invokeMethod('selectAll');
    } on PlatformException catch (e) {
      debugPrint('Error selecting all: ${e.message}');
    }
  }

  /// Get currently selected text
  Future<String?> getSelectedText() async {
    try {
      final result = await _methodChannel.invokeMethod<String>('getSelectedText');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error getting selected text: ${e.message}');
      return null;
    }
  }

  /// Set composing text (for text suggestions)
  Future<void> setComposingText(String text) async {
    try {
      await _methodChannel.invokeMethod('setComposingText', {'text': text});
    } on PlatformException catch (e) {
      debugPrint('Error setting composing text: ${e.message}');
    }
  }

  /// Commit composing text
  Future<void> commitComposingText(String text) async {
    try {
      await _methodChannel.invokeMethod('commitComposingText', {'text': text});
    } on PlatformException catch (e) {
      debugPrint('Error committing composing text: ${e.message}');
    }
  }

  /// Finish composing text
  Future<void> finishComposing() async {
    try {
      await _methodChannel.invokeMethod('finishComposing');
    } on PlatformException catch (e) {
      debugPrint('Error finishing composing: ${e.message}');
    }
  }

  // ====== Keyboard Actions ======

  /// Perform editor action (done, go, search, etc.)
  Future<void> commitAction(String action) async {
    try {
      await _methodChannel.invokeMethod('commitAction', {'action': action});
    } on PlatformException catch (e) {
      debugPrint('Error committing action: ${e.message}');
    }
  }

  /// Hide keyboard
  Future<void> hideKeyboard() async {
    try {
      await _methodChannel.invokeMethod('hideKeyboard');
    } on PlatformException catch (e) {
      debugPrint('Error hiding keyboard: ${e.message}');
    }
  }

  /// Switch to previous input method
  Future<void> switchToPreviousInputMethod() async {
    try {
      await _methodChannel.invokeMethod('switchToPreviousInputMethod');
    } on PlatformException catch (e) {
      debugPrint('Error switching IME: ${e.message}');
    }
  }

  /// Show input method picker
  Future<void> showInputMethodPicker() async {
    try {
      await _methodChannel.invokeMethod('showInputMethodPicker');
    } on PlatformException catch (e) {
      debugPrint('Error showing IME picker: ${e.message}');
    }
  }

  // ====== Editor Info ======

  /// Get current editor info
  Future<Map<String, dynamic>> getEditorInfo() async {
    try {
      final result = await _methodChannel.invokeMethod<Map>('getEditorInfo');
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      debugPrint('Error getting editor info: ${e.message}');
      return {};
    }
  }

  // ====== Haptics ======

  /// Perform haptic feedback (vibration)
  Future<void> vibrate({int duration = 30, int strength = 128}) async {
    try {
      await _methodChannel.invokeMethod('vibrate', {
        'duration': duration,
        'strength': strength,
      });
    } on PlatformException catch (e) {
      debugPrint('Error vibrating: ${e.message}');
    }
  }

  // ====== Clipboard Operations ======

  /// Get text from clipboard
  Future<String?> getClipboardText() async {
    try {
      final result = await _inputChannel.invokeMethod<String>('getClipboardText');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error getting clipboard text: ${e.message}');
      return null;
    }
  }

  /// Set text to clipboard
  Future<void> setClipboardText(String text) async {
    try {
      await _inputChannel.invokeMethod('setClipboardText', {'text': text});
    } on PlatformException catch (e) {
      debugPrint('Error setting clipboard text: ${e.message}');
    }
  }

  /// Get surrounding text
  Future<Map<dynamic, dynamic>?> getSurroundingText({
    int before = 50,
    int after = 50,
  }) async {
    try {
      final result = await _inputChannel.invokeMethod<Map>(
        'getSurroundingText',
        {'before': before, 'after': after},
      );
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error getting surrounding text: ${e.message}');
      return null;
    }
  }

  /// Get IME state
  Future<Map<dynamic, dynamic>?> getImeState() async {
    try {
      final result = await _inputChannel.invokeMethod<Map>('getImeState');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error getting IME state: ${e.message}');
      return null;
    }
  }
}

/// Service for handling settings channel operations
class SettingsChannelService {
  static final SettingsChannelService _instance = SettingsChannelService._internal();

  factory SettingsChannelService() {
    return _instance;
  }

  SettingsChannelService._internal();

  static final _channel = MethodChannel(AppConstants.settingsChannel);

  /// Check if keyboard is enabled
  Future<bool> isKeyboardEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isKeyboardEnabled') ?? false;
    } catch (e) {
      debugPrint('Error checking keyboard enabled: $e');
      return false;
    }
  }

  /// Check if keyboard is selected as default
  Future<bool> isKeyboardSelected() async {
    try {
      return await _channel.invokeMethod<bool>('isKeyboardSelected') ?? false;
    } catch (e) {
      debugPrint('Error checking keyboard selected: $e');
      return false;
    }
  }

  /// Open keyboard settings
  Future<void> openKeyboardSettings() async {
    try {
      await _channel.invokeMethod('openKeyboardSettings');
    } catch (e) {
      debugPrint('Error opening keyboard settings: $e');
    }
  }

  /// Open input method picker
  Future<void> openInputMethodPicker() async {
    try {
      await _channel.invokeMethod('openInputMethodPicker');
    } catch (e) {
      debugPrint('Error opening input method picker: $e');
    }
  }

  /// Get Android version
  Future<int> getAndroidVersion() async {
    try {
      return await _channel.invokeMethod<int>('getAndroidVersion') ?? 0;
    } catch (e) {
      debugPrint('Error getting Android version: $e');
      return 0;
    }
  }
}