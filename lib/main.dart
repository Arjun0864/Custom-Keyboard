import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/app_constants.dart';
import 'app_theme.dart';
import 'data/settings_repository.dart';
import 'ui/keyboard_screen.dart';
import 'enable_keyboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await SettingsRepository.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Determine if running as keyboard or settings app
  final isKeyboardMode = await _isKeyboardMode();

  runApp(
    ProviderScope(
      child: FlutterBoardApp(isKeyboardMode: isKeyboardMode),
    ),
  );
}

/// Check if the app is running in IME mode
Future<bool> _isKeyboardMode() async {
  try {
    final result = await const MethodChannel(AppConstants.methodChannel)
        .invokeMethod<bool>('isKeyboardMode');
    return result ?? false;
  } catch (e) {
    debugPrint('Error checking keyboard mode: $e');
    return false;
  }
}

/// Main app router based on mode
class FlutterBoardApp extends ConsumerWidget {
  final bool isKeyboardMode;

  const FlutterBoardApp({
    super.key,
    required this.isKeyboardMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlutterBoard',
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: isKeyboardMode 
        ? const KeyboardScreen()
        : const FlutterBoardSettingsApp(),
    );
  }
}

/// Keyboard UI (shown inside IME Service)
class FlutterBoardKeyboardApp extends ConsumerWidget {
  const FlutterBoardKeyboardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlutterBoard',
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const KeyboardScreen(),
    );
  }
}

/// Settings App (shown in launcher)
class FlutterBoardSettingsApp extends ConsumerWidget {
  const FlutterBoardSettingsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlutterBoard Settings',
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SettingsHomePage(),
    );
  }
}

/// Main settings page with enable keyboard option
class SettingsHomePage extends StatefulWidget {
  const SettingsHomePage({super.key});

  @override
  State<SettingsHomePage> createState() => _SettingsHomePageState();
}

class _SettingsHomePageState extends State<SettingsHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterBoard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const EnableKeyboardScreen();
      case 1:
        return const _SettingsPage();
      case 2:
        return const _AboutPage();
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Settings page with theme and keyboard customization
class _SettingsPage extends ConsumerWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Theme Mode
        const SizedBox(height: 16),
        Text(
          'Appearance',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme Mode'),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(label: Text('Light'), value: ThemeMode.light),
                    ButtonSegment(label: Text('Dark'), value: ThemeMode.dark),
                    ButtonSegment(label: Text('System'), value: ThemeMode.system),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    ref.read(themeModeProvider.notifier)
                        .setThemeMode(newSelection.first);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// About page with keyboard information
class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.keyboard,
              size: 50,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'FlutterBoard',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Version 1.0.0',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'FlutterBoard is a modern, feature-rich Android system keyboard built with Flutter. '
                  'It provides intelligent suggestions, emoji support, clipboard management, and dark mode.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Features',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFeatureItem('Smart Suggestions'),
                _buildFeatureItem('Emoji & Symbols'),
                _buildFeatureItem('Clipboard Manager'),
                _buildFeatureItem('Multi-Language Support'),
                _buildFeatureItem('Dark/Light Theme'),
                _buildFeatureItem('Customizable Layout'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(feature),
        ],
      ),
    );
  }
}

