import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';

enum KeyboardLayer { main, symbols1, symbols2, emoji, clipboard, translator, voice }
enum ShiftState { off, single, locked }

class KeyboardState {
  final KeyboardLayer layer;
  final ShiftState shiftState;
  final String currentLanguage;
  final bool isGliding;
  final String composingText;
  final String previousWord;
  final bool showSuggestions;
  final bool isIncognito;
  final bool showCursorControl;
  final double keyboardHeight;
  final String lastKey;
  final bool showKeyPreview;
  final bool showEmojiPanel;
  final bool showClipboardPanel;
  final bool isFloating;
  final KeyboardTheme currentTheme;
  final List<String> suggestions;
  final Map<String, List<String>> currentLayout;

  KeyboardState({
    this.layer = KeyboardLayer.main,
    this.shiftState = ShiftState.off,
    this.currentLanguage = 'en',
    this.isGliding = false,
    this.composingText = '',
    this.previousWord = '',
    this.showSuggestions = true,
    this.isIncognito = false,
    this.showCursorControl = false,
    this.keyboardHeight = 260.0,
    this.lastKey = '',
    this.showKeyPreview = false,
    this.showEmojiPanel = false,
    this.showClipboardPanel = false,
    this.isFloating = false,
    KeyboardTheme? currentTheme,
    this.suggestions = const [],
    this.currentLayout = const {
      'qwerty': ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      'asdfgh': ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    },
  }) : currentTheme = currentTheme ?? AppTheme.materialLightTheme;

  KeyboardState copyWith({
    KeyboardLayer? layer,
    ShiftState? shiftState,
    String? currentLanguage,
    bool? isGliding,
    String? composingText,
    String? previousWord,
    bool? showSuggestions,
    bool? isIncognito,
    bool? showCursorControl,
    double? keyboardHeight,
    String? lastKey,
    bool? showKeyPreview,
    bool? showEmojiPanel,
    bool? showClipboardPanel,
    bool? isFloating,
    KeyboardTheme? currentTheme,
    List<String>? suggestions,
    Map<String, List<String>>? currentLayout,
  }) {
    return KeyboardState(
      layer: layer ?? this.layer,
      shiftState: shiftState ?? this.shiftState,
      currentLanguage: currentLanguage ?? this.currentLanguage,
      isGliding: isGliding ?? this.isGliding,
      composingText: composingText ?? this.composingText,
      previousWord: previousWord ?? this.previousWord,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      isIncognito: isIncognito ?? this.isIncognito,
      showCursorControl: showCursorControl ?? this.showCursorControl,
      keyboardHeight: keyboardHeight ?? this.keyboardHeight,
      lastKey: lastKey ?? this.lastKey,
      showKeyPreview: showKeyPreview ?? this.showKeyPreview,
      showEmojiPanel: showEmojiPanel ?? this.showEmojiPanel,
      showClipboardPanel: showClipboardPanel ?? this.showClipboardPanel,
      isFloating: isFloating ?? this.isFloating,
      currentTheme: currentTheme ?? this.currentTheme,
      suggestions: suggestions ?? this.suggestions,
      currentLayout: currentLayout ?? this.currentLayout,
    );
  }

  bool get isShifted => shiftState != ShiftState.off;
  bool get isCapsLocked => shiftState == ShiftState.locked;
}

final keyboardStateProvider = StateNotifierProvider<KeyboardStateNotifier, KeyboardState>((ref) {
  return KeyboardStateNotifier();
});

class KeyboardStateNotifier extends StateNotifier<KeyboardState> {
  KeyboardStateNotifier() : super(KeyboardState());

  void setLayer(KeyboardLayer layer) {
    state = state.copyWith(layer: layer);
  }

  void toggleShift() {
    final next = switch (state.shiftState) {
      ShiftState.off => ShiftState.single,
      ShiftState.single => ShiftState.locked,
      ShiftState.locked => ShiftState.off,
    };
    state = state.copyWith(shiftState: next);
  }

  void setShift(ShiftState shift) {
    state = state.copyWith(shiftState: shift);
  }

  void autoShiftOff() {
    if (state.shiftState == ShiftState.single) {
      state = state.copyWith(shiftState: ShiftState.off);
    }
  }

  void setLanguage(String language) {
    state = state.copyWith(currentLanguage: language);
  }

  void setGliding(bool isGliding) {
    state = state.copyWith(isGliding: isGliding);
  }

  void setComposingText(String text) {
    state = state.copyWith(composingText: text);
  }

  void setPreviousWord(String word) {
    state = state.copyWith(previousWord: word);
  }

  void toggleCursorControl() {
    state = state.copyWith(showCursorControl: !state.showCursorControl);
  }

  void toggleIncognito() {
    state = state.copyWith(isIncognito: !state.isIncognito);
  }

  void onKeyTap(String value) {
    state = state.copyWith(lastKey: value, showKeyPreview: true);
    Future.delayed(const Duration(milliseconds: 100), () {
      state = state.copyWith(showKeyPreview: false);
    });
  }

  void onKeyLongPress(String value) {
    state = state.copyWith(lastKey: value);
  }

  void updateTheme(KeyboardTheme theme) {
    state = state.copyWith(currentTheme: theme);
  }

  void setKeyboardHeight(double height) {
    state = state.copyWith(keyboardHeight: height);
  }

  void toggleEmojiPanel() {
    // Close other panels when opening emoji
    state = state.copyWith(
      showEmojiPanel: !state.showEmojiPanel,
      showClipboardPanel: false,
    );
  }

  void toggleClipboardPanel() {
    // Close other panels when opening clipboard
    state = state.copyWith(
      showClipboardPanel: !state.showClipboardPanel,
      showEmojiPanel: false,
    );
  }

  void setFloating(bool floating) {
    state = state.copyWith(isFloating: floating);
  }

  void setSuggestions(List<String> suggestions) {
    state = state.copyWith(suggestions: suggestions);
  }

  void acceptSuggestion(String text) {
    // This would be called from the suggestion bar
    state = state.copyWith(suggestions: []);
  }

  void setLayout(Map<String, List<String>> layout) {
    state = state.copyWith(currentLayout: layout);
  }
}