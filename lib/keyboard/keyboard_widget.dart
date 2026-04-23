import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'keyboard_controller.dart';
import 'keyboard_theme.dart';
import 'toolbar_row.dart';
import 'qwerty_panel.dart';
import 'symbols_panel.dart';
import 'emoji_panel.dart';
import 'clipboard_panel.dart';
import 'voice_panel.dart';

const _iQwerty    = 0;
const _iSymbols   = 1;
const _iEmoji     = 2;
const _iClipboard = 3;
const _iVoice     = 4;

class KeyboardWidget extends StatefulWidget {
  const KeyboardWidget({super.key});

  @override
  State<KeyboardWidget> createState() => _KeyboardWidgetState();
}

class _KeyboardWidgetState extends State<KeyboardWidget> {
  int _panel = _iQwerty;

  ToolbarAction? get _activeToolbar => switch (_panel) {
    _iEmoji     => ToolbarAction.emoji,
    _iClipboard => ToolbarAction.more,
    _iVoice     => ToolbarAction.voice,
    _           => null,
  };

  void _go(int idx) =>
      setState(() => _panel = (_panel == idx) ? _iQwerty : idx);

  void _onToolbar(ToolbarAction a) {
    switch (a) {
      case ToolbarAction.emoji:    _go(_iEmoji);
      case ToolbarAction.more:     _go(_iClipboard);
      case ToolbarAction.voice:    _go(_iVoice);
      default: break;
    }
  }

  // Fixed pixel height for each panel — avoids any percentage calculation
  // that would be wrong in IME context (MediaQuery returns full screen height).
  // These match real Samsung keyboard dimensions.
  double get _panelHeight {
    switch (_panel) {
      case _iEmoji:
      case _iClipboard:
      case _iVoice:
        return 260;
      default:
        return 235; // QWERTY + symbols: toolbar(44) + divider(1) + keys(~190)
    }
  }

  @override
  Widget build(BuildContext context) {
    final t    = KbTheme.of(context);
    final ctrl = context.read<KeyboardController>();

    return Material(
      color: t.bg,
      child: Column(
        // mainAxisSize.min + no Expanded at root = WRAP_CONTENT behavior
        // The Kotlin FrameLayout(WRAP_CONTENT) will size to exactly this.
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Toolbar ────────────────────────────────────────────────────────
          ToolbarRow(active: _activeToolbar, onTap: _onToolbar),
          Divider(height: 1, thickness: 1, color: t.divider),

          // ── Panel area — fixed height, IndexedStack keeps all alive ────────
          SizedBox(
            height: _panelHeight,
            child: IndexedStack(
              index: _panel,
              children: [
                QwertyPanel(
                  controller: ctrl,
                  onNumbers: () => setState(() => _panel = _iSymbols),
                  onEmoji:   () => setState(() => _panel = _iEmoji),
                ),
                SymbolsPanel(
                  controller: ctrl,
                  onQwerty: () => setState(() => _panel = _iQwerty),
                  onEmoji:  () => setState(() => _panel = _iEmoji),
                ),
                EmojiPanel(controller: ctrl),
                ClipboardPanel(controller: ctrl),
                VoicePanel(
                  onCancel: () => setState(() => _panel = _iQwerty),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
