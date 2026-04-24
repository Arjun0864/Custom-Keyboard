import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'themes/theme_provider.dart';
import 'features/clipboard/clipboard_database.dart';
import 'features/glide_typing/glide_controller.dart';
import 'features/settings/goodlock_settings_screen.dart';
import 'keyboard/keyboard_controller.dart';

// Flutter is ONLY used for the Settings screen (MainActivity).
// The keyboard IME is pure native Kotlin — no Flutter rendering in IME.
// This eliminates the black/white screen flash completely.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ClipboardDatabase().initialize();
  runApp(const ABKeyboardSettingsApp());
}

class ABKeyboardSettingsApp extends StatelessWidget {
  const ABKeyboardSettingsApp({super.key});

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
