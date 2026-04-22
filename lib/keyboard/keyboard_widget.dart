import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'keyboard_controller.dart';
import 'keyboard_theme.dart';
import 'toolbar_row.dart';
import 'suggestion_bar.dart';
import 'qwerty_panel.dart';
import 'symbols_panel.dart';
import 'emoji_panel.dart';
import 'clipboard_panel.dart';
import 'voice_panel.dart';

// Panel index constants — used with IndexedStack
const int _kQwerty    = 0;
const int _kSymbols   = 1;
const int _kEmoji     = 2;
const int _kClipboard = 3;
const int _kVoice     = 4;

/// Root keyboard widget.
///
/// KEY FIXES applied here:
/// 1. IndexedStack — ALL panels stay mounted; only the active one is visible.
///    This is the ONLY correct way to prevent blank-screen flashes on switch.
/// 2. Fixed SizedBox height at root — never Expanded, never IntrinsicHeight.
/// 3. Height is calculated once per build from MediaQuery (portrait 38%, landscape 50%).
/// 4. No if/else widget swapping, no Navigator, no AnimatedSwitcher.
class KeyboardWidget extends StatefulWidget {
  const KeyboardWidget({super.key});

  @override
  State<KeyboardWidget> createState() => _KeyboardWidgetState();
}

class _KeyboardWidgetState extends State<KeyboardWidget> {
  int _panelIndex = _kQwerty;

  // Toolbar action that maps to the active panel (for icon highlight)
  ToolbarAction? get _activeToolbarAction => switch (_panelIndex) {
        _kEmoji     => ToolbarAction.emoji,
        _kClipboard => ToolbarAction.clipboard,
        _kVoice     => ToolbarAction.voice,
        _           => null,
      };

  // ── Responsive height ──────────────────────────────────────────────────────
  // FIXED: Calculated from MediaQuery every build — handles orientation changes.
  // NEVER use Expanded at root — causes overflow / blank screen in IME context.
  double _keyboardHeight(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isPortrait = mq.orientation == Orientation.portrait;
    // Portrait: 38% of screen height  |  Landscape: 50%
    return isPortrait
        ? (mq.size.height * 0.38).clamp(220.0, 360.0)
        : (mq.size.height * 0.50).clamp(160.0, 300.0);
  }

  // ── Panel switching ────────────────────────────────────────────────────────
  void _switchPanel(int index) {
    if (_panelIndex == index) {
      // Tapping the active panel icon → go back to QWERTY
      setState(() => _panelIndex = _kQwerty);
    } else {
      setState(() => _panelIndex = index);
    }
  }

  void _onToolbarAction(ToolbarAction action) {
    switch (action) {
      case ToolbarAction.emoji:
        _switchPanel(_kEmoji);
      case ToolbarAction.clipboard:
        _switchPanel(_kClipboard);
      case ToolbarAction.voice:
        _switchPanel(_kVoice);
      case ToolbarAction.settings:
        // Settings opens as a full-screen activity — no panel switch needed
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = KbColors.of(context);
    final ctrl   = context.read<KeyboardController>();
    final height = _keyboardHeight(context);

    return SizedBox(
      // FIXED: Fixed height — never changes during panel switches.
      // This is what prevents layout recalculation and blank flashes.
      height: height,
      child: ColoredBox(
        color: colors.keyboardBg,
        child: Column(
          children: [
            // ── Toolbar ──────────────────────────────────────────────────────
            ToolbarRow(
              activeAction: _activeToolbarAction,
              onAction: _onToolbarAction,
            ),

            // ── Suggestion bar ───────────────────────────────────────────────
            SuggestionBar(
              suggestions: const ['the', 'and', 'for'], // replace with real suggestions
              onTap: (word) => ctrl.insertCharacter(word),
            ),

            // ── Panel area ───────────────────────────────────────────────────
            // FIXED: IndexedStack keeps ALL panels mounted at all times.
            // Switching panels = changing `index` only. Zero widget rebuilds.
            // Zero blank flashes. Zero layout recalculation.
            Expanded(
              child: IndexedStack(
                index: _panelIndex,
                children: [
                  // index 0 — QWERTY
                  QwertyPanel(
                    controller: ctrl,
                    onSwitchToNumbers: () => setState(() => _panelIndex = _kSymbols),
                    onSwitchToEmoji:   () => setState(() => _panelIndex = _kEmoji),
                  ),

                  // index 1 — Numbers / Symbols
                  SymbolsPanel(
                    controller: ctrl,
                    onSwitchToQwerty: () => setState(() => _panelIndex = _kQwerty),
                    onSwitchToEmoji:  () => setState(() => _panelIndex = _kEmoji),
                  ),

                  // index 2 — Emoji
                  EmojiPanel(controller: ctrl),

                  // index 3 — Clipboard
                  ClipboardPanel(controller: ctrl),

                  // index 4 — Voice
                  VoicePanel(
                    onCancel: () => setState(() => _panelIndex = _kQwerty),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
