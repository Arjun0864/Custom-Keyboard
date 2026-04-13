import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(keyboardThemeProvider);
    final allThemes = KeyboardThemes.allThemes;

    return Scaffold(
      appBar: AppBar(title: const Text("Select Theme")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          for (final theme in allThemes)
            _themeCard(context, theme, currentTheme, ref),
        ],
      ),
    );
  }

  Widget _themeCard(
    BuildContext context,
    KeyboardTheme theme,
    KeyboardTheme currentTheme,
    WidgetRef ref,
  ) {
    final isSelected = theme.name == currentTheme.name;
    
    return Card(
      color: theme.backgroundColor,
      child: InkWell(
        onTap: () {
          ref.read(keyboardThemeProvider.notifier).setTheme(theme);
          Navigator.pop(context);
        },
        child: Stack(
          children: [
            Center(
              child: Text(
                theme.name,
                style: TextStyle(
                  color: theme.keyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isSelected)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle, color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
