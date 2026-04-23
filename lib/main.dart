import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'keyboard/keyboard_controller.dart';
import 'keyboard/keyboard_widget.dart';
import 'themes/theme_provider.dart';
import 'features/clipboard/clipboard_database.dart';
import 'features/glide_typing/glide_controller.dart';
import 'features/settings/goodlock_settings_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TWO ENTRY POINTS
//
// main()          → called by FlutterBoardIME (the IME service)
//                   Shows ONLY the keyboard widget, transparent background.
//
// settingsMain()  → called by MainActivity (launcher icon)
//                   Shows the settings screen.
//
// This completely eliminates the async isKeyboardMode() check that was
// causing the white/blank screen flash.
// ─────────────────────────────────────────────────────────────────────────────

/// Entry point used by the IME service (FlutterBoardIME).
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ClipboardDatabase().initialize();
  runApp(const _KeyboardApp());
}

/// Entry point used by the launcher activity (MainActivity).
@pragma('vm:entry-point')
void settingsMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _SettingsApp());
}

// ─── Keyboard app (IME mode) ──────────────────────────────────────────────────

class _KeyboardApp extends StatelessWidget {
  const _KeyboardApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => KeyboardController()),
        ChangeNotifierProvider(create: (_) => GlideController()),
        Provider(create: (_) => ClipboardDatabase()),
      ],
      builder: (context, _) {
        final theme = context.read<ThemeProvider>();
        return FutureBuilder<void>(
          future: theme.isInitialized ? Future.value() : theme.initialize(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              // Show keyboard bg color immediately — never white
              return const MaterialApp(
                home: Scaffold(backgroundColor: Color(0xFFD1D5DB)),
              );
            }
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                // Transparent so the IME window bg shows through
                backgroundColor: Colors.transparent,
                body: KeyboardWidget(),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Settings app (launcher mode) ────────────────────────────────────────────

class _SettingsApp extends StatelessWidget {
  const _SettingsApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => KeyboardController()),
        ChangeNotifierProvider(create: (_) => GlideController()),
        Provider(create: (_) => ClipboardDatabase()),
      ],
      builder: (context, _) {
        final theme = context.read<ThemeProvider>();
        return FutureBuilder<void>(
          future: theme.isInitialized ? Future.value() : theme.initialize(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                home: Scaffold(backgroundColor: Colors.white),
              );
            }
            return Consumer<ThemeProvider>(
              builder: (_, tp, __) => MaterialApp(
                title: 'AB Keyboard',
                debugShowCheckedModeBanner: false,
                theme: tp.getThemeData(),
                home: const GoodLockSettingsScreen(),
              ),
            );
          },
        );
      },
    );
  }
}
