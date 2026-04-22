import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'keyboard/keyboard_controller.dart';
import 'themes/theme_provider.dart';
import 'features/clipboard/clipboard_database.dart';
import 'features/glide_typing/glide_controller.dart';
import 'keyboard/keyboard_widget.dart';
import 'features/settings/goodlock_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize databases and providers
  await ClipboardDatabase().initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const FlutterBoardApp());
}

/// Main app with all providers integrated
class FlutterBoardApp extends StatelessWidget {
  const FlutterBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme provider for dynamic theming
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),

        // Keyboard controller for input management
        ChangeNotifierProvider(
          create: (_) => KeyboardController(),
        ),

        // Glide typing controller for swipe input
        ChangeNotifierProvider(
          create: (_) => GlideController(),
        ),

        // Clipboard database for history
        Provider(
          create: (_) => ClipboardDatabase(),
        ),
      ],
      builder: (context, _) {
        // Initialize theme provider on first build
        final themeProvider = context.read<ThemeProvider>();
        
        return FutureBuilder<void>(
          future: themeProvider.isInitialized 
              ? Future.value() 
              : themeProvider.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue[400],
                    ),
                  ),
                ),
              );
            }

            return Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return MaterialApp(
                  title: 'AB Keyboard',
                  debugShowCheckedModeBanner: false,
                  theme: themeProvider.getThemeData(),
                  home: const AppHomeScreen(),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Main screen that decides whether to show keyboard or settings
class AppHomeScreen extends StatefulWidget {
  const AppHomeScreen({super.key});

  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  bool _isKeyboardMode = false;

  @override
  void initState() {
    super.initState();
    _checkKeyboardMode();
  }

  Future<void> _checkKeyboardMode() async {
    try {
      // Check if we're running as IME (keyboard mode)
      const platform = MethodChannel('com.flutterboard/keyboard');
      final result = await platform.invokeMethod('isKeyboardMode');
      if (result == true) {
        setState(() {
          _isKeyboardMode = true;
        });
      }
    } catch (e) {
      // If method call fails, we're not in keyboard mode
      setState(() {
        _isKeyboardMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isKeyboardMode) {
      // Show keyboard when used as IME
      return const KeyboardScreen();
    } else {
      // Show settings when app is opened from launcher
      return const SettingsScreen();
    }
  }
}

/// Keyboard screen that displays the integrated keyboard (for IME mode)
class KeyboardScreen extends StatefulWidget {
  const KeyboardScreen({super.key});

  @override
  State<KeyboardScreen> createState() => _KeyboardScreenState();
}

class _KeyboardScreenState extends State<KeyboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return const KeyboardWidget();
        },
      ),
    );
  }
}

/// Settings screen that shows when app is opened from launcher
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GoodLockSettingsScreen();
  }
}

