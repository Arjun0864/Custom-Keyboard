import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/keyboard_service.dart';
import 'keyboard_state.dart';
import 'keyboard_layout.dart';
import 'suggestion_bar_and_chip.dart';
import 'emoji_panel.dart';
import 'clipboard_panel.dart';
import 'dart:ui' as ui;

class FlutterBoardView extends ConsumerStatefulWidget {
  final bool isFloatingMode;
  final Alignment? floatingPosition;

  const FlutterBoardView({
    super.key,
    this.isFloatingMode = false,
    this.floatingPosition,
  });

  @override
  ConsumerState<FlutterBoardView> createState() => _FlutterBoardViewState();
}

class _FlutterBoardViewState extends ConsumerState<FlutterBoardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _keyboardService = KeyboardService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    _initKeyboardService();
  }

  Future<void> _initKeyboardService() async {
    await _keyboardService.initialize();
    _keyboardService.onKeyboardEvent((event) {
      if (mounted) {
        _handleKeyboardEvent(event);
      }
    });
  }

  void _handleKeyboardEvent(dynamic event) {
    final eventMap = event as Map<dynamic, dynamic>;
    final type = eventMap['type'] as String?;
    
    switch (type) {
      case 'startInput':
        debugPrint('Input started');
        break;
      case 'finishInput':
        debugPrint('Input finished');
        break;
      case 'selectionUpdate':
        debugPrint('Selection updated');
        break;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(keyboardStateProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (widget.isFloatingMode) {
      return _buildFloatingKeyboard(context, state, isDarkMode);
    }

    return _buildStandardKeyboard(context, state, isDarkMode);
  }

  Widget _buildStandardKeyboard(
    BuildContext context,
    KeyboardState state,
    bool isDarkMode,
  ) {
    return Container(
      color: state.currentTheme.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Suggestion Bar with smooth transition
          if (state.showSuggestions)
            ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
              ),
              child: const SuggestionBar(),
            ),

          // Main Keyboard Layout
          Expanded(
            child: KeyboardLayout(layer: state.layer),
          ),

          // Bottom Panel Selector with smooth transitions
          _buildPanelSelector(state, isDarkMode),

          // Emoji Panel
          if (state.showEmojiPanel)
            SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeInOut,
              ),
              child: const EmojiPanel(),
            ),

          // Clipboard Panel
          if (state.showClipboardPanel)
            SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeInOut,
              ),
              child: const ClipboardPanel(),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingKeyboard(
    BuildContext context,
    KeyboardState state,
    bool isDarkMode,
  ) {
    return Positioned(
      bottom: 100,
      right: 20,
      left: 20,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: state.currentTheme.backgroundColor.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDarkMode 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : Colors.black.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KeyboardLayout(layer: state.layer),
                    if (state.showSuggestions)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: SuggestionBar(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelSelector(KeyboardState state, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(
            icon: Icons.text_fields,
            isActive: !state.showEmojiPanel && !state.showClipboardPanel,
            onTap: () => _togglePanel('keyboard'),
          ),
          _buildIconButton(
            icon: Icons.emoji_emotions_outlined,
            isActive: state.showEmojiPanel,
            onTap: () => _togglePanel('emoji'),
          ),
          _buildIconButton(
            icon: Icons.assignment_turned_in_outlined,
            isActive: state.showClipboardPanel,
            onTap: () => _togglePanel('clipboard'),
          ),
          _buildIconButton(
            icon: Icons.settings_outlined,
            isActive: false,
            onTap: () => _showSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive 
          ? Colors.blue.withValues(alpha: 0.2)
          : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: isActive ? Colors.blue : _getKeyTextColor(),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  void _togglePanel(String panel) {
    final notifier = ref.read(keyboardStateProvider.notifier);
    if (panel == 'emoji') {
      notifier.toggleEmojiPanel();
    } else if (panel == 'clipboard') {
      notifier.toggleClipboardPanel();
    }
  }

  void _showSettings(BuildContext context) {
    // Navigate to settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings coming soon')),
    );
  }

  Color _getKeyTextColor() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode
      ? Colors.white
      : Colors.black;
  }
}
