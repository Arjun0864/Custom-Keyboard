import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'key_button.dart';
import 'keyboard_controller.dart';
import '../themes/theme_provider.dart';
import '../features/clipboard/clipboard_view.dart';
import '../features/emoji/emoji_keyboard.dart';
import '../features/glide_typing/glide_controller.dart';
import '../features/settings/settings_screen.dart';

/// View state enum for switching between keyboard, emoji, clipboard, settings
enum KeyboardViewState {
  main,
  emoji,
  clipboard,
  settings,
}

/// KeyboardLayout defines the structure of the keyboard rows
class KeyboardRow {
  final List<KeyboardKeyItem> keys;
  final double rowHeight;

  KeyboardRow({
    required this.keys,
    this.rowHeight = 50,
  });
}

/// A single key item in the keyboard layout
class KeyboardKeyItem {
  final String label;
  final KeyType keyType;
  final double flex;
  final IconData? icon;
  final String? symbolLabel;

  KeyboardKeyItem({
    required this.label,
    this.keyType = KeyType.character,
    this.flex = 1,
    this.icon,
    this.symbolLabel,
  });
}

/// Full integrated keyboard widget with all features
///
/// Features:
/// - 5 rows: numbers, QWERTY, ASDFGH, ZXCVBN, action keys
/// - Word suggestions bar at top
/// - Toggle buttons: clipboard, emoji, settings
/// - Glide typing support
/// - Emoji keyboard view
/// - Clipboard history view
/// - Settings view
/// - Real-time theme integration
class KeyboardWidget extends StatefulWidget {
  /// Background color of the keyboard
  final Color? backgroundColor;

  /// Color for regular character keys
  final Color? keyColor;

  /// Font size for key text
  final double fontSize;

  /// Key border radius
  final double keyBorderRadius;

  /// Height of the keyboard
  final double? height;

  /// Spacing between keys
  final double keySpacing;

  const KeyboardWidget({
    Key? key,
    this.backgroundColor,
    this.keyColor,
    this.fontSize = 16,
    this.keyBorderRadius = 4,
    this.height,
    this.keySpacing = 4,
  }) : super(key: key);

  @override
  State<KeyboardWidget> createState() => _KeyboardWidgetState();
}

class _KeyboardWidgetState extends State<KeyboardWidget> {
  // View state
  KeyboardViewState _currentView = KeyboardViewState.main;

  // Keyboard layout
  late List<KeyboardKeyItem> numberRow;
  late List<KeyboardKeyItem> row1;
  late List<KeyboardKeyItem> row2;
  late List<KeyboardKeyItem> row3;
  late List<KeyboardKeyItem> row4;

  // Glide typing
  late GlideController _glideController;

  @override
  void initState() {
    super.initState();
    _initializeKeyboardLayout();
    _glideController = GlideController();
  }

  @override
  void dispose() {
    _glideController.dispose();
    super.dispose();
  }

  /// Initialize keyboard layout
  void _initializeKeyboardLayout() {
    // Number row: 1 2 3 4 5 6 7 8 9 0
    numberRow = [
      KeyboardKeyItem(label: '1', keyType: KeyType.character),
      KeyboardKeyItem(label: '2', keyType: KeyType.character),
      KeyboardKeyItem(label: '3', keyType: KeyType.character),
      KeyboardKeyItem(label: '4', keyType: KeyType.character),
      KeyboardKeyItem(label: '5', keyType: KeyType.character),
      KeyboardKeyItem(label: '6', keyType: KeyType.character),
      KeyboardKeyItem(label: '7', keyType: KeyType.character),
      KeyboardKeyItem(label: '8', keyType: KeyType.character),
      KeyboardKeyItem(label: '9', keyType: KeyType.character),
      KeyboardKeyItem(label: '0', keyType: KeyType.character),
    ];

    // Row 1: QWERTYUIOP
    row1 = [
      KeyboardKeyItem(label: 'q', keyType: KeyType.character),
      KeyboardKeyItem(label: 'w', keyType: KeyType.character),
      KeyboardKeyItem(label: 'e', keyType: KeyType.character),
      KeyboardKeyItem(label: 'r', keyType: KeyType.character),
      KeyboardKeyItem(label: 't', keyType: KeyType.character),
      KeyboardKeyItem(label: 'y', keyType: KeyType.character),
      KeyboardKeyItem(label: 'u', keyType: KeyType.character),
      KeyboardKeyItem(label: 'i', keyType: KeyType.character),
      KeyboardKeyItem(label: 'o', keyType: KeyType.character),
      KeyboardKeyItem(label: 'p', keyType: KeyType.character),
    ];

    // Row 2: ASDFGHJKL
    row2 = [
      KeyboardKeyItem(label: 'a', keyType: KeyType.character),
      KeyboardKeyItem(label: 's', keyType: KeyType.character),
      KeyboardKeyItem(label: 'd', keyType: KeyType.character),
      KeyboardKeyItem(label: 'f', keyType: KeyType.character),
      KeyboardKeyItem(label: 'g', keyType: KeyType.character),
      KeyboardKeyItem(label: 'h', keyType: KeyType.character),
      KeyboardKeyItem(label: 'j', keyType: KeyType.character),
      KeyboardKeyItem(label: 'k', keyType: KeyType.character),
      KeyboardKeyItem(label: 'l', keyType: KeyType.character),
    ];

    // Row 3: ZXCVBNM
    row3 = [
      KeyboardKeyItem(label: 'z', keyType: KeyType.character),
      KeyboardKeyItem(label: 'x', keyType: KeyType.character),
      KeyboardKeyItem(label: 'c', keyType: KeyType.character),
      KeyboardKeyItem(label: 'v', keyType: KeyType.character),
      KeyboardKeyItem(label: 'b', keyType: KeyType.character),
      KeyboardKeyItem(label: 'n', keyType: KeyType.character),
      KeyboardKeyItem(label: 'm', keyType: KeyType.character),
    ];

    // Row 4: Action keys (now with emoji, clipboard, settings)
    row4 = [
      KeyboardKeyItem(
        label: '⇧',
        keyType: KeyType.shift,
        flex: 1,
      ),
      KeyboardKeyItem(
        label: 'space',
        keyType: KeyType.space,
        flex: 3,
      ),
      KeyboardKeyItem(
        label: '⌫',
        keyType: KeyType.backspace,
        flex: 1,
        icon: Icons.backspace_outlined,
      ),
      KeyboardKeyItem(
        label: '↵',
        keyType: KeyType.enter,
        flex: 1,
        icon: Icons.keyboard_return,
      ),
    ];
  }

  /// Handle key press
  void _handleKeyPress(KeyboardKeyItem item, KeyboardController keyboardController) {
    switch (item.keyType) {
      case KeyType.character:
        final char = keyboardController.shiftState == ShiftState.off
            ? item.label.toLowerCase()
            : item.label.toUpperCase();
        keyboardController.insertCharacter(char);
        break;

      case KeyType.backspace:
        keyboardController.handleBackspace();
        break;

      case KeyType.enter:
        keyboardController.handleEnter();
        break;

      case KeyType.shift:
        keyboardController.toggleShift();
        break;

      case KeyType.space:
        keyboardController.insertCharacter(' ');
        break;

      default:
        break;
    }
  }

  /// Build a single key button widget
  Widget _buildKey(
    KeyboardKeyItem item,
    KeyboardController keyboardController,
    ThemeProvider themeProvider,
  ) {
    return Flexible(
      flex: (item.flex * 10).toInt(),
      child: Padding(
        padding: EdgeInsets.all(widget.keySpacing / 2),
        child: KeyButton(
          label: item.label,
          keyType: item.keyType,
          fontSize: widget.fontSize,
          borderRadius: widget.keyBorderRadius,
          backgroundColor: _getKeyColor(item.keyType, themeProvider),
          onPressed: () => _handleKeyPress(item, keyboardController),
          onCharacterInput: (char) => keyboardController.insertCharacter(char),
          isShiftActive: keyboardController.shiftState != ShiftState.off,
          isSymbolMode: keyboardController.currentLayout == KeyboardLayout.symbols,
          icon: item.icon,
        ),
      ),
    );
  }

  /// Get color for key based on type and theme
  Color _getKeyColor(KeyType keyType, ThemeProvider themeProvider) {
    switch (keyType) {
      case KeyType.backspace:
      case KeyType.enter:
      case KeyType.shift:
        return themeProvider.accentColor.withValues(alpha: 0.8);
      default:
        return themeProvider.backgroundColor;
    }
  }

  /// Build a keyboard row
  Widget _buildRow(
    List<KeyboardKeyItem> rowKeys,
    KeyboardController keyboardController,
    ThemeProvider themeProvider, {
    double height = 50,
  }) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rowKeys
            .map((item) => _buildKey(item, keyboardController, themeProvider))
            .toList(),
      ),
    );
  }

  /// Build top bar with word suggestions, emoji, clipboard, settings buttons
  Widget _buildTopBar(
    KeyboardController keyboardController,
    ThemeProvider themeProvider,
  ) {
    return Container(
      color: themeProvider.getKeyboardBackgroundColor(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        children: [
          // Word suggestions row
          Consumer<GlideController>(
            builder: (context, glideController, _) {
              final suggestions = glideController.getCurrentSuggestions();
              return SizedBox(
                height: 36,
                child: suggestions.isEmpty
                    ? Center(
                        child: Text(
                          'Type to see suggestions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = suggestions[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Material(
                              color: themeProvider.accentColor,
                              borderRadius: BorderRadius.circular(6),
                              child: InkWell(
                                onTap: () {
                                  keyboardController
                                      .insertCharacter(suggestion.word);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Center(
                                    child: Text(
                                      suggestion.word,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              );
            },
          ),

          const SizedBox(height: 6),

          // Control buttons row
          Row(
            children: [
              // Emoji button
              Material(
                color: _currentView == KeyboardViewState.emoji
                    ? themeProvider.accentColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentView = _currentView == KeyboardViewState.emoji
                          ? KeyboardViewState.main
                          : KeyboardViewState.emoji;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.emoji_emotions,
                      color: _currentView == KeyboardViewState.emoji
                          ? Colors.white
                          : themeProvider.accentColor,
                      size: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // Clipboard button
              Material(
                color: _currentView == KeyboardViewState.clipboard
                    ? themeProvider.accentColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentView = _currentView == KeyboardViewState.clipboard
                          ? KeyboardViewState.main
                          : KeyboardViewState.clipboard;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.history,
                      color: _currentView == KeyboardViewState.clipboard
                          ? Colors.white
                          : themeProvider.accentColor,
                      size: 20,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Settings button
              Material(
                color: _currentView == KeyboardViewState.settings
                    ? themeProvider.accentColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentView = _currentView == KeyboardViewState.settings
                          ? KeyboardViewState.main
                          : KeyboardViewState.settings;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.settings,
                      color: _currentView == KeyboardViewState.settings
                          ? Colors.white
                          : themeProvider.accentColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<KeyboardController, ThemeProvider>(
      builder: (context, keyboardController, themeProvider, _) {
        return Container(
          color: themeProvider.getKeyboardBackgroundColor(),
          child: Column(
            children: [
              // Top bar with suggestions and controls
              _buildTopBar(keyboardController, themeProvider),

              // Main content (keyboard, emoji, clipboard, or settings)
              Expanded(
                child: _buildContent(
                  keyboardController,
                  themeProvider,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build content based on current view state
  Widget _buildContent(
    KeyboardController keyboardController,
    ThemeProvider themeProvider,
  ) {
    switch (_currentView) {
      case KeyboardViewState.emoji:
        return EmojiKeyboard(
          keyboardController: keyboardController,
          onBack: () {
            setState(() {
              _currentView = KeyboardViewState.main;
            });
          },
          height: 300,
        );

      case KeyboardViewState.clipboard:
        return ClipboardView(
          onClipSelected: (clip) {
            keyboardController.insertCharacter(clip);
            setState(() {
              _currentView = KeyboardViewState.main;
            });
          },
          onClipDeleted: () {},
          onClipPinned: () {},
          height: 100,
        );

      case KeyboardViewState.settings:
        return SettingsScreen();

      case KeyboardViewState.main:
      default:
        return _buildKeyboardMain(
          keyboardController,
          themeProvider,
        );
    }
  }

  /// Build the main keyboard view
  Widget _buildKeyboardMain(
    KeyboardController keyboardController,
    ThemeProvider themeProvider,
  ) {
    return Container(
      color: themeProvider.getKeyboardBackgroundColor(),
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      child: Column(
        children: [
          // Number row
          _buildRow(numberRow, keyboardController, themeProvider,
              height: 45),
          SizedBox(height: widget.keySpacing),

          // QWERTY row
          _buildRow(row1, keyboardController, themeProvider, height: 50),
          SizedBox(height: widget.keySpacing),

          // ASDFGH row
          _buildRow(row2, keyboardController, themeProvider, height: 50),
          SizedBox(height: widget.keySpacing),

          // ZXCVBNM row
          _buildRow(row3, keyboardController, themeProvider, height: 50),
          SizedBox(height: widget.keySpacing),

          // Action row
          _buildRow(row4, keyboardController, themeProvider, height: 50),
        ],
      ),
    );
  }
}

