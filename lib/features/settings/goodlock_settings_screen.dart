import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_provider.dart';

/// GoodLock-style keyboard settings screen with live preview
class GoodLockSettingsScreen extends StatefulWidget {
  const GoodLockSettingsScreen({Key? key}) : super(key: key);

  @override
  State<GoodLockSettingsScreen> createState() => _GoodLockSettingsScreenState();
}

class _GoodLockSettingsScreenState extends State<GoodLockSettingsScreen> {
  final TextEditingController _themeNameController = TextEditingController();
  bool _showSaveDialog = false;

  @override
  void dispose() {
    _themeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Keyboard Style'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _showResetDialog(context, themeProvider),
                tooltip: 'Reset to default',
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Live preview section
                _buildPreviewSection(context, themeProvider),

                const Divider(thickness: 1, height: 0),

                // Settings sections
                _buildAppearanceSection(context, themeProvider),
                const SizedBox(height: 8),

                _buildLayoutSection(context, themeProvider),
                const SizedBox(height: 8),

                _buildKeysSection(context, themeProvider),
                const SizedBox(height: 8),

                _buildTypographySection(context, themeProvider),
                const SizedBox(height: 8),

                _buildBackgroundSection(context, themeProvider),
                const SizedBox(height: 8),

                _buildEffectsSection(context, themeProvider),
                const SizedBox(height: 8),

                _buildAdvancedSection(context, themeProvider),
                const SizedBox(height: 16),

                // Save theme button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _showSaveDialog = true),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Current Theme'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Saved themes section
                if (themeProvider.customThemes.isNotEmpty)
                  _buildCustomThemesSection(context, themeProvider),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Live keyboard preview
  Widget _buildPreviewSection(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildMiniKeyboard(themeProvider),
          ),
        ],
      ),
    );
  }

  /// Mini keyboard preview widget
  Widget _buildMiniKeyboard(ThemeProvider themeProvider) {
    return Container(
      height: 140,
      color: themeProvider.backgroundColor,
      padding: EdgeInsets.all(themeProvider.keyGapSpacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // First row (QWERTY)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Q', 'W', 'E', 'R', 'T'].map((key) {
              return _buildMiniKey(key, themeProvider);
            }).toList(),
          ),
          // Second row (ASDFG)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['A', 'S', 'D', 'F', 'G'].map((key) {
              return _buildMiniKey(key, themeProvider);
            }).toList(),
          ),
          // Third row (ZXCVB)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Z', 'X', 'C', 'V', 'B'].map((key) {
              return _buildMiniKey(key, themeProvider);
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Individual mini key
  Widget _buildMiniKey(String label, ThemeProvider themeProvider) {
    BorderRadius borderRadius;
    switch (themeProvider.keyShape) {
      case KeyShape.rectangle:
        borderRadius = BorderRadius.zero;
      case KeyShape.rounded:
        borderRadius = BorderRadius.circular(
          themeProvider.keyBorderRadius.clamp(0, 8),
        );
      case KeyShape.bubble:
        borderRadius = BorderRadius.circular(
          themeProvider.keyBorderRadius.clamp(0, 20),
        );
      case KeyShape.minimal:
        borderRadius = BorderRadius.circular(2);
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: themeProvider.accentColor.withOpacity(themeProvider.keyOpacity),
        borderRadius: borderRadius,
        boxShadow: themeProvider.keyShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(themeProvider.shadowIntensity * 0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                )
              ]
            : [],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: themeProvider.fontWeight,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ===== SETTINGS SECTIONS =====

  /// APPEARANCE section
  Widget _buildAppearanceSection(BuildContext context, ThemeProvider themeProvider) {
    return _buildExpandableSection(
      title: 'APPEARANCE',
      icon: Icons.palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color mode selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Color Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildModeChip('Light', ColorMode.light, themeProvider),
                    const SizedBox(width: 8),
                    _buildModeChip('Dark', ColorMode.dark, themeProvider),
                    const SizedBox(width: 8),
                    _buildModeChip('Auto', ColorMode.auto, themeProvider),
                  ],
                ),
              ],
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // Color palette
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Accent Color', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: ThemeProvider.samsungColors.length + 1,
                  itemBuilder: (context, index) {
                    if (index == ThemeProvider.samsungColors.length) {
                      return GestureDetector(
                        onTap: () => _showColorPickerDialog(context, themeProvider),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Colors.grey),
                        ),
                      );
                    }
                    final color = ThemeProvider.samsungColors[index];
                    final isSelected = themeProvider.accentColor == color.color &&
                        !themeProvider.isCustomColor;
                    return GestureDetector(
                      onTap: () => themeProvider.setAccentColor(color.color),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.color,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // Key opacity
          _buildSliderSetting(
            'Key Opacity',
            themeProvider.keyOpacity,
            0.0,
            1.0,
            (value) => themeProvider.setKeyOpacity(value),
          ),
        ],
      ),
    );
  }

  /// LAYOUT section
  Widget _buildLayoutSection(BuildContext context, ThemeProvider themeProvider) {
    return _buildExpandableSection(
      title: 'LAYOUT',
      icon: Icons.smartphone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Keyboard height presets
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Keyboard Height', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildHeightCard('Compact', 200, themeProvider),
                    const SizedBox(width: 8),
                    _buildHeightCard('Normal', 250, themeProvider),
                    const SizedBox(width: 8),
                    _buildHeightCard('Large', 300, themeProvider),
                    const SizedBox(width: 8),
                    _buildHeightCard('XL', 350, themeProvider),
                  ],
                ),
              ],
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // One-handed mode
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('One-Handed Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildModeChip('Off', OneHandedMode.off, themeProvider, isOneHanded: true),
                    const SizedBox(width: 8),
                    _buildModeChip('Left', OneHandedMode.left, themeProvider, isOneHanded: true),
                    const SizedBox(width: 8),
                    _buildModeChip('Right', OneHandedMode.right, themeProvider, isOneHanded: true),
                  ],
                ),
                if (themeProvider.oneHandedMode != OneHandedMode.off)
                  _buildSliderSetting(
                    'Shift Amount: ${themeProvider.oneHandedShiftPercent.toStringAsFixed(0)}%',
                    themeProvider.oneHandedShiftPercent,
                    10.0,
                    50.0,
                    (value) => themeProvider.setOneHandedShift(value),
                  ),
              ],
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // Floating mode
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text('Floating Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Switch(
                  value: themeProvider.floatingMode,
                  onChanged: (value) => themeProvider.setFloatingMode(value),
                ),
              ],
            ),
          ),

          if (themeProvider.floatingMode)
            _buildSliderSetting(
              'Size: ${(themeProvider.floatingSize * 100).toStringAsFixed(0)}%',
              themeProvider.floatingSize,
              0.5,
              1.0,
              (value) => themeProvider.setFloatingSize(value),
            ),

          // Row stagger toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text('Symmetrical Layout', style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Switch(
                  value: themeProvider.rowStagger,
                  onChanged: (value) => themeProvider.setRowStagger(value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// KEYS section
  Widget _buildKeysSection(BuildContext context, ThemeProvider themeProvider) {
    return _buildExpandableSection(
      title: 'KEYS',
      icon: Icons.grid_3x3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key shape selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Key Shape', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShapeButton(
                      'Rectangle',
                      KeyShape.rectangle,
                      Icons.rectangle_outlined,
                      themeProvider,
                    ),
                    _buildShapeButton(
                      'Rounded',
                      KeyShape.rounded,
                      Icons.rounded_corner,
                      themeProvider,
                    ),
                    _buildShapeButton(
                      'Bubble',
                      KeyShape.bubble,
                      Icons.circle_outlined,
                      themeProvider,
                    ),
                    _buildShapeButton(
                      'Minimal',
                      KeyShape.minimal,
                      Icons.crop_square,
                      themeProvider,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // Border radius slider
          _buildSliderSetting(
            'Border Radius: ${themeProvider.keyBorderRadius.toStringAsFixed(1)}px',
            themeProvider.keyBorderRadius,
            0.0,
            20.0,
            (value) => themeProvider.setKeyBorderRadius(value),
          ),

          // Gap spacing slider
          _buildSliderSetting(
            'Gap Spacing: ${themeProvider.keyGapSpacing.toStringAsFixed(1)}px',
            themeProvider.keyGapSpacing,
            2.0,
            8.0,
            (value) => themeProvider.setKeyGapSpacing(value),
          ),

          // Shadow toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text('Key Shadow', style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Switch(
                  value: themeProvider.keyShadow,
                  onChanged: (value) => themeProvider.setKeyShadow(value),
                ),
              ],
            ),
          ),

          if (themeProvider.keyShadow)
            _buildSliderSetting(
              'Shadow Intensity: ${(themeProvider.shadowIntensity * 100).toStringAsFixed(0)}%',
              themeProvider.shadowIntensity,
              0.0,
              1.0,
              (value) => themeProvider.setShadowIntensity(value),
            ),
        ],
      ),
    );
  }

  /// TYPOGRAPHY section
  Widget _buildTypographySection(BuildContext context, ThemeProvider themeProvider) {
    return _buildExpandableSection(
      title: 'TYPOGRAPHY',
      icon: Icons.text_fields,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Font family selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Font Family', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Default', 'Rounded', 'Sharp', 'Mono', 'Serif']
                        .map((family) {
                      final isSelected = themeProvider.fontFamily == family;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(family),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              themeProvider.setFontFamily(family);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // Font size slider
          _buildSliderSetting(
            'Font Size: ${themeProvider.fontSize.toStringAsFixed(0)}px',
            themeProvider.fontSize,
            12.0,
            18.0,
            (value) => themeProvider.setFontSize(value),
          ),

          // Font weight selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Font Weight', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildFontWeightButton('Light', FontWeight.w300, themeProvider),
                    const SizedBox(width: 8),
                    _buildFontWeightButton('Regular', FontWeight.w400, themeProvider),
                    const SizedBox(width: 8),
                    _buildFontWeightButton('Medium', FontWeight.w500, themeProvider),
                    const SizedBox(width: 8),
                    _buildFontWeightButton('Bold', FontWeight.w700, themeProvider),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// BACKGROUND section
  Widget _buildBackgroundSection(BuildContext context, ThemeProvider themeProvider) {
    return _buildExpandableSection(
      title: 'BACKGROUND',
      icon: Icons.wallpaper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Background style selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Style', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBackgroundStyleChip('Solid', BackgroundStyle.solid, themeProvider),
                    const SizedBox(width: 8),
                    _buildBackgroundStyleChip('Gradient', BackgroundStyle.gradient, themeProvider),
                    const SizedBox(width: 8),
                    _buildBackgroundStyleChip('Blur', BackgroundStyle.blur, themeProvider),
                  ],
                ),
              ],
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // Color picker for background
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text('Background Color', style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showBackgroundColorPicker(context, themeProvider),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: themeProvider.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Image button
          if (themeProvider.backgroundStyle == BackgroundStyle.image)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement image picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image picker coming soon')),
                  );
                },
                icon: const Icon(Icons.image),
                label: const Text('Choose Image'),
              ),
            ),
        ],
      ),
    );
  }

  /// EFFECTS section
  Widget _buildEffectsSection(BuildContext context, ThemeProvider themeProvider) {
    return _buildExpandableSection(
      title: 'EFFECTS',
      icon: Icons.auto_awesome,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vibration intensity
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Vibration', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildVibrationButton('Off', 0, themeProvider),
                    const SizedBox(width: 8),
                    _buildVibrationButton('Light', 1, themeProvider),
                    const SizedBox(width: 8),
                    _buildVibrationButton('Medium', 2, themeProvider),
                    const SizedBox(width: 8),
                    _buildVibrationButton('Strong', 3, themeProvider),
                  ],
                ),
              ],
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // Sound theme
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sound Theme', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildSoundChip('Off', SoundTheme.off, themeProvider),
                    _buildSoundChip('Click', SoundTheme.click, themeProvider),
                    _buildSoundChip('Typewriter', SoundTheme.typewriter, themeProvider),
                    _buildSoundChip('Soft', SoundTheme.soft, themeProvider),
                    _buildSoundChip('Pop', SoundTheme.pop, themeProvider),
                  ],
                ),
              ],
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // Key animation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Key Press Animation', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildAnimationButton('None', KeyAnimation.none, themeProvider),
                    const SizedBox(width: 8),
                    _buildAnimationButton('Scale', KeyAnimation.scale, themeProvider),
                    const SizedBox(width: 8),
                    _buildAnimationButton('Ripple', KeyAnimation.ripple, themeProvider),
                    const SizedBox(width: 8),
                    _buildAnimationButton('Bounce', KeyAnimation.bounce, themeProvider),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ADVANCED section
  Widget _buildAdvancedSection(BuildContext context, ThemeProvider themeProvider) {
    return _buildExpandableSection(
      title: 'ADVANCED',
      icon: Icons.tune,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji style
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Emoji Style', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildEmojiStyleButton('System', EmojiStyle.system, themeProvider),
                    const SizedBox(width: 8),
                    _buildEmojiStyleButton('iOS', EmojiStyle.ios, themeProvider),
                    const SizedBox(width: 8),
                    _buildEmojiStyleButton('Flat', EmojiStyle.flat, themeProvider),
                    const SizedBox(width: 8),
                    _buildEmojiStyleButton('Outlined', EmojiStyle.outlined, themeProvider),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Custom themes section
  Widget _buildCustomThemesSection(BuildContext context, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Themes (${themeProvider.customThemes.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: themeProvider.customThemes.length,
            itemBuilder: (context, index) {
              final theme = themeProvider.customThemes[index];
              return Card(
                child: ListTile(
                  title: Text(theme.name),
                  subtitle: Text(
                    'Created ${theme.createdAt.toString().split('.')[0]}',
                  ),
                  onTap: () => themeProvider.loadCustomTheme(theme),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmDialog(
                      context,
                      themeProvider,
                      theme.id,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ===== HELPER WIDGETS =====

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      children: [child],
    );
  }

  Widget _buildModeChip(String label, dynamic value, ThemeProvider themeProvider,
      {bool isOneHanded = false}) {
    final isSelected = isOneHanded
        ? themeProvider.oneHandedMode == value
        : themeProvider.colorMode == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          if (isOneHanded) {
            themeProvider.setOneHandedMode(value);
          } else {
            themeProvider.setColorMode(value);
          }
        }
      },
    );
  }

  Widget _buildHeightCard(String label, double height, ThemeProvider themeProvider) {
    final isSelected = themeProvider.keyboardHeight == height;
    return Expanded(
      child: GestureDetector(
        onTap: () => themeProvider.setKeyboardHeight(height),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[100] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
          ),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 4),
              Text('${height.toInt()}px', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShapeButton(
    String label,
    KeyShape shape,
    IconData icon,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.keyShape == shape;
    return Column(
      children: [
        GestureDetector(
          onTap: () => themeProvider.setKeyShape(shape),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
            ),
            child: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildSliderSetting(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildFontWeightButton(
    String label,
    FontWeight weight,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.fontWeight == weight;
    return Expanded(
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontWeight: weight)),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) themeProvider.setFontWeight(weight);
        },
      ),
    );
  }

  Widget _buildBackgroundStyleChip(
    String label,
    BackgroundStyle style,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.backgroundStyle == style;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) themeProvider.setBackgroundStyle(style);
      },
    );
  }

  Widget _buildVibrationButton(
    String label,
    int intensity,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.vibrationIntensity == intensity;
    return Expanded(
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) themeProvider.setVibrationIntensity(intensity);
        },
      ),
    );
  }

  Widget _buildSoundChip(
    String label,
    SoundTheme sound,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.soundTheme == sound;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) themeProvider.setSoundTheme(sound);
      },
    );
  }

  Widget _buildAnimationButton(
    String label,
    KeyAnimation animation,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.keyAnimation == animation;
    return Expanded(
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) themeProvider.setKeyAnimation(animation);
        },
      ),
    );
  }

  Widget _buildEmojiStyleButton(
    String label,
    EmojiStyle style,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.emojiStyle == style;
    return Expanded(
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) themeProvider.setEmojiStyle(style);
        },
      ),
    );
  }

  // ===== DIALOGS =====

  void _showColorPickerDialog(BuildContext context, ThemeProvider themeProvider) {
    final TextEditingController hexController = TextEditingController(
      text: themeProvider.customColorHex,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Color'),
        content: TextField(
          controller: hexController,
          decoration: const InputDecoration(
            hintText: '#RRGGBB',
            prefixText: '#',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              themeProvider.setCustomColor('#${hexController.text}');
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showBackgroundColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Background Color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            children: [
              Colors.white,
              Colors.grey[100]!,
              Colors.grey[200]!,
              Colors.grey[300]!,
              Colors.grey[400]!,
              Colors.black,
              Colors.blue[50]!,
              Colors.blue[100]!,
            ]
                .map((color) => GestureDetector(
              onTap: () {
                themeProvider.setBackgroundColor(color);
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ))
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Default?'),
        content: const Text('This will reset all settings to their default values.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              themeProvider.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    ThemeProvider themeProvider,
    String themeId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Theme?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              themeProvider.deleteCustomTheme(themeId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSaveDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSaveThemeDialog(context);
      });
      _showSaveDialog = false;
    }
    return super.build(context);
  }

  void _showSaveThemeDialog(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Theme'),
        content: TextField(
          controller: _themeNameController,
          decoration: const InputDecoration(
            hintText: 'Enter theme name',
            labelText: 'Theme Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _themeNameController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_themeNameController.text.isNotEmpty) {
                themeProvider.saveAsCustomTheme(_themeNameController.text);
                _themeNameController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme saved successfully')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
