import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_provider.dart';
import '../../keyboard/keyboard_widget.dart';

/// Full settings and customization screen for the keyboard
///
/// Features:
/// - Dark mode toggle
/// - 6 accent color options
/// - Key size slider
/// - Border radius slider
/// - Feature toggles: vibration, sound, auto-correct, glide typing
/// - Keyboard height selector
/// - Live keyboard preview
/// - Reset to defaults button
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _themeProvider = context.read<ThemeProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _showResetDialog,
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Theme settings section
            _buildThemeSection(),

            // Feature toggles section
            _buildFeaturesSection(),

            // Customization section
            _buildCustomizationSection(),

            // Keyboard preview section
            _buildPreviewSection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Build theme settings section
  Widget _buildThemeSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Theme'),

            // Dark mode toggle
            ListTile(
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeProvider.getPrimaryColor(),
              ),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.setDarkMode(value),
              ),
            ),

            const Divider(height: 1),

            // Accent color selector
            Padding(
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
                  _buildAccentColorPicker(themeProvider),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  /// Build accent color picker row
  Widget _buildAccentColorPicker(ThemeProvider themeProvider) {
    final colors = AccentColor.values;
    final colorNames = ['Blue', 'Green', 'Purple', 'Orange', 'Red', 'Teal'];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = themeProvider.accentColor == color;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => themeProvider.setAccentColor(color),
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  color: _getColorForAccent(color),
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(
                          color: Colors.grey,
                          width: 3,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      colorNames[index],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build features section
  Widget _buildFeaturesSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Features'),

            // Vibration toggle
            ListTile(
              leading: Icon(
                Icons.vibration,
                color: themeProvider.getPrimaryColor(),
              ),
              title: const Text('Vibration Feedback'),
              trailing: Switch(
                value: themeProvider.vibration,
                onChanged: (value) => themeProvider.setVibration(value),
              ),
            ),

            const Divider(height: 1),

            // Sound toggle
            ListTile(
              leading: Icon(
                Icons.volume_up,
                color: themeProvider.getPrimaryColor(),
              ),
              title: const Text('Key Sound'),
              trailing: Switch(
                value: themeProvider.sound,
                onChanged: (value) => themeProvider.setSound(value),
              ),
            ),

            const Divider(height: 1),

            // Auto-correct toggle
            ListTile(
              leading: Icon(
                Icons.spell_check,
                color: themeProvider.getPrimaryColor(),
              ),
              title: const Text('Auto-Correct'),
              trailing: Switch(
                value: themeProvider.autoCorrect,
                onChanged: (value) => themeProvider.setAutoCorrect(value),
              ),
            ),

            const Divider(height: 1),

            // Glide typing toggle
            ListTile(
              leading: Icon(
                Icons.gesture,
                color: themeProvider.getPrimaryColor(),
              ),
              title: const Text('Glide Typing'),
              subtitle: const Text('Swipe to type'),
              trailing: Switch(
                value: themeProvider.glideTyping,
                onChanged: (value) => themeProvider.setGlideTyping(value),
              ),
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// Build customization section
  Widget _buildCustomizationSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Customization'),

            // Font size buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font Size',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSizeButton(
                        'Small',
                        FontSizeOption.small,
                        themeProvider,
                      ),
                      const SizedBox(width: 8),
                      _buildSizeButton(
                        'Medium',
                        FontSizeOption.medium,
                        themeProvider,
                      ),
                      const SizedBox(width: 8),
                      _buildSizeButton(
                        'Large',
                        FontSizeOption.large,
                        themeProvider,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, indent: 16, endIndent: 16),

            // Keyboard height
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keyboard Height',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildHeightButton(
                        'Short',
                        KeyboardHeightOption.short,
                        themeProvider,
                      ),
                      const SizedBox(width: 8),
                      _buildHeightButton(
                        'Normal',
                        KeyboardHeightOption.normal,
                        themeProvider,
                      ),
                      const SizedBox(width: 8),
                      _buildHeightButton(
                        'Tall',
                        KeyboardHeightOption.tall,
                        themeProvider,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, indent: 16, endIndent: 16),

            // Key border radius slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Key Border Radius',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        '${themeProvider.keyBorderRadius.toStringAsFixed(1)} px',
                        style: TextStyle(
                          color: themeProvider.getPrimaryColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: themeProvider.keyBorderRadius,
                    min: 0,
                    max: 16,
                    divisions: 16,
                    onChanged: (value) {
                      themeProvider.setKeyBorderRadius(value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// Build keyboard preview section
  Widget _buildPreviewSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Preview'),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: KeyboardWidget(
                height: 200,
                backgroundColor: themeProvider.getKeyboardBackgroundColor(),
                keyColor: themeProvider.getKeyColor(),
                fontSize: themeProvider.getFontSize(),
                keyBorderRadius: themeProvider.keyBorderRadius,
                keySpacing: 4,
              ),
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  /// Build size option button
  Widget _buildSizeButton(
    String label,
    FontSizeOption option,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.fontSize == option;

    return Expanded(
      child: Material(
        color: isSelected
            ? themeProvider.getPrimaryColor()
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => themeProvider.setFontSize(option),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build height option button
  Widget _buildHeightButton(
    String label,
    KeyboardHeightOption option,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.keyboardHeight == option;

    return Expanded(
      child: Material(
        color: isSelected
            ? themeProvider.getPrimaryColor()
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => themeProvider.setKeyboardHeight(option),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Show reset confirmation dialog
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _themeProvider.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Get color for accent color option
  Color _getColorForAccent(AccentColor color) {
    switch (color) {
      case AccentColor.blue:
        return Colors.blue;
      case AccentColor.green:
        return Colors.green;
      case AccentColor.purple:
        return Colors.purple;
      case AccentColor.orange:
        return Colors.orange;
      case AccentColor.red:
        return Colors.red;
      case AccentColor.teal:
        return Colors.teal;
    }
  }
}
