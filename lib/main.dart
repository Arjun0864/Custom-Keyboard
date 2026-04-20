import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'keyboard/keyboard_controller.dart';
import 'themes/theme_provider.dart';
import 'features/clipboard/clipboard_database.dart';
import 'keyboard/keyboard_widget.dart';

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
  const FlutterBoardApp({Key? key}) : super(key: key);

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
                  title: 'FlutterBoard',
                  debugShowCheckedModeBanner: false,
                  theme: themeProvider.getThemeData(),
                  home: const KeyboardScreen(),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Main keyboard screen that displays the integrated keyboard
class KeyboardScreen extends StatefulWidget {
  const KeyboardScreen({Key? key}) : super(key: key);

  @override
  State<KeyboardScreen> createState() => _KeyboardScreenState();
}

class _KeyboardScreenState extends State<KeyboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return Container(
            color: themeProvider.getKeyboardBackgroundColor(),
            child: const SafeArea(
              child: KeyboardWidget(),
            ),
          );
        },
      ),
    );
  }
}

