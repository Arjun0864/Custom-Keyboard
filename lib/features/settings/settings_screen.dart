import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_provider.dart';

/// Settings screen for keyboard customization
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Theme'),
                
                // Color mode selector
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Color Mode'),
                  subtitle: Text(themeProvider.colorMode.toString().split('.')[1]),
                ),

                // Accent color picker
                _buildAccentColorSection(themeProvider),

                const Divider(),
                _buildSectionHeader('Customization'),

                // Key opacity
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Key Opacity: ${(themeProvider.keyOpacity * 100).toStringAsFixed(0)}%'),
                      Slider(
                        value: themeProvider.keyOpacity,
                        onChanged: (value) => themeProvider.setKeyOpacity(value),
                        min: 0.3,
                        max: 1.0,
                      ),
                    ],
                  ),
                ),

                // Key border radius
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Key Border Radius: ${themeProvider.keyBorderRadius.toStringAsFixed(1)}'),
                      Slider(
                        value: themeProvider.keyBorderRadius,
                        onChanged: (value) => themeProvider.setKeyBorderRadius(value),
                        min: 0.0,
                        max: 20.0,
                      ),
                    ],
                  ),
                ),

                // Font size
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Font Size: ${themeProvider.fontSize.toStringAsFixed(0)}'),
                      Slider(
                        value: themeProvider.fontSize,
                        onChanged: (value) => themeProvider.setFontSize(value),
                        min: 12.0,
                        max: 20.0,
                      ),
                    ],
                  ),
                ),

                // Vibration intensity
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vibration: ${themeProvider.vibrationIntensity}/3'),
                      Slider(
                        value: themeProvider.vibrationIntensity.toDouble(),
                        onChanged: (value) => themeProvider.setVibrationIntensity(value.toInt()),
                        min: 0,
                        max: 3,
                        divisions: 3,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build accent color picker
  Widget _buildAccentColorSection(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accent Color',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ThemeProvider.samsungColors.map((preset) {
                final isSelected = themeProvider.accentColor == preset.color;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => themeProvider.setAccentColor(preset.color),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: preset.color,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: Colors.grey, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(Icons.check_circle, color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
