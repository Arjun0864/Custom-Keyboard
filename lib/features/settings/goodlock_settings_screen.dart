import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_provider.dart';

/// Modern Samsung-style keyboard settings screen
class GoodLockSettingsScreen extends StatefulWidget {
  const GoodLockSettingsScreen({super.key});

  @override
  State<GoodLockSettingsScreen> createState() => _GoodLockSettingsScreenState();
}

class _GoodLockSettingsScreenState extends State<GoodLockSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        final isDark = theme.colorMode == ColorMode.dark ||
            (theme.colorMode == ColorMode.auto &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);
        final bg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
        final cardBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subColor = isDark ? Colors.white54 : Colors.black45;

        return Theme(
          data: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            colorSchemeSeed: theme.accentColor,
          ),
          child: Scaffold(
            backgroundColor: bg,
            appBar: AppBar(
              backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              elevation: 0,
              title: Text('Keyboard Settings',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w600)),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: theme.accentColor,
                labelColor: theme.accentColor,
                unselectedLabelColor: subColor,
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(icon: Icon(Icons.palette_outlined, size: 20), text: 'Style'),
                  Tab(icon: Icon(Icons.grid_view_outlined, size: 20), text: 'Keys'),
                  Tab(icon: Icon(Icons.vibration_outlined, size: 20), text: 'Feedback'),
                  Tab(icon: Icon(Icons.tune_outlined, size: 20), text: 'Layout'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _StyleTab(theme: theme, bg: bg, cardBg: cardBg, textColor: textColor, subColor: subColor),
                _KeysTab(theme: theme, bg: bg, cardBg: cardBg, textColor: textColor, subColor: subColor),
                _FeedbackTab(theme: theme, bg: bg, cardBg: cardBg, textColor: textColor, subColor: subColor),
                _LayoutTab(theme: theme, bg: bg, cardBg: cardBg, textColor: textColor, subColor: subColor),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Style Tab ───────────────────────────────────────────────────────────────

class _StyleTab extends StatelessWidget {
  final ThemeProvider theme;
  final Color bg, cardBg, textColor, subColor;
  const _StyleTab({required this.theme, required this.bg, required this.cardBg, required this.textColor, required this.subColor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Live preview
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Preview', textColor),
              const SizedBox(height: 12),
              _MiniKeyboardPreview(theme: theme),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Color mode
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Color Mode', textColor),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ModeChip('Light', theme.colorMode == ColorMode.light, theme.accentColor,
                      () => theme.setColorMode(ColorMode.light)),
                  const SizedBox(width: 8),
                  _ModeChip('Dark', theme.colorMode == ColorMode.dark, theme.accentColor,
                      () => theme.setColorMode(ColorMode.dark)),
                  const SizedBox(width: 8),
                  _ModeChip('Auto', theme.colorMode == ColorMode.auto, theme.accentColor,
                      () => theme.setColorMode(ColorMode.auto)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Accent color
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Accent Color', textColor),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ThemeProvider.samsungColors.map((c) {
                  final selected = theme.accentColor == c.color && !theme.isCustomColor;
                  return GestureDetector(
                    onTap: () => theme.setAccentColor(c.color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c.color,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: selected
                            ? [BoxShadow(color: c.color.withValues(alpha: 0.5), blurRadius: 8)]
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Key opacity
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle('Key Opacity', textColor),
                  Text('${(theme.keyOpacity * 100).toInt()}%',
                      style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.w600)),
                ],
              ),
              Slider(
                value: theme.keyOpacity,
                min: 0.3,
                max: 1.0,
                activeColor: theme.accentColor,
                onChanged: theme.setKeyOpacity,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Keys Tab ────────────────────────────────────────────────────────────────

class _KeysTab extends StatelessWidget {
  final ThemeProvider theme;
  final Color bg, cardBg, textColor, subColor;
  const _KeysTab({required this.theme, required this.bg, required this.cardBg, required this.textColor, required this.subColor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Key shape
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Key Shape', textColor),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ShapeOption('Square', KeyShape.rectangle, Icons.crop_square, theme),
                  _ShapeOption('Rounded', KeyShape.rounded, Icons.rounded_corner, theme),
                  _ShapeOption('Bubble', KeyShape.bubble, Icons.circle_outlined, theme),
                  _ShapeOption('Minimal', KeyShape.minimal, Icons.remove, theme),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Border radius
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle('Corner Radius', textColor),
                  Text('${theme.keyBorderRadius.toInt()}px',
                      style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.w600)),
                ],
              ),
              Slider(
                value: theme.keyBorderRadius,
                min: 0,
                max: 20,
                activeColor: theme.accentColor,
                onChanged: theme.setKeyBorderRadius,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Key gap
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle('Key Spacing', textColor),
                  Text('${theme.keyGapSpacing.toInt()}px',
                      style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.w600)),
                ],
              ),
              Slider(
                value: theme.keyGapSpacing,
                min: 2,
                max: 8,
                activeColor: theme.accentColor,
                onChanged: theme.setKeyGapSpacing,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Shadow
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle('Key Shadow', textColor),
                  Switch(
                    value: theme.keyShadow,
                    activeThumbColor: theme.accentColor,
                    onChanged: theme.setKeyShadow,
                  ),
                ],
              ),
              if (theme.keyShadow) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Intensity', style: TextStyle(color: subColor, fontSize: 13)),
                    Text('${(theme.shadowIntensity * 100).toInt()}%',
                        style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                Slider(
                  value: theme.shadowIntensity,
                  min: 0,
                  max: 1,
                  activeColor: theme.accentColor,
                  onChanged: theme.setShadowIntensity,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Font size
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle('Font Size', textColor),
                  Text('${theme.fontSize.toInt()}px',
                      style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.w600)),
                ],
              ),
              Slider(
                value: theme.fontSize,
                min: 12,
                max: 20,
                activeColor: theme.accentColor,
                onChanged: theme.setFontSize,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Feedback Tab ─────────────────────────────────────────────────────────────

class _FeedbackTab extends StatelessWidget {
  final ThemeProvider theme;
  final Color bg, cardBg, textColor, subColor;
  const _FeedbackTab({required this.theme, required this.bg, required this.cardBg, required this.textColor, required this.subColor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Vibration
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Vibration', textColor),
              const SizedBox(height: 12),
              Row(
                children: [
                  _FeedbackChip('Off', 0, theme),
                  const SizedBox(width: 8),
                  _FeedbackChip('Light', 1, theme),
                  const SizedBox(width: 8),
                  _FeedbackChip('Medium', 2, theme),
                  const SizedBox(width: 8),
                  _FeedbackChip('Strong', 3, theme),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Sound
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Sound Theme', textColor),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SoundChip('Off', SoundTheme.off, theme),
                  _SoundChip('Click', SoundTheme.click, theme),
                  _SoundChip('Typewriter', SoundTheme.typewriter, theme),
                  _SoundChip('Soft', SoundTheme.soft, theme),
                  _SoundChip('Pop', SoundTheme.pop, theme),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Key animation
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Key Animation', textColor),
              const SizedBox(height: 12),
              Row(
                children: [
                  _AnimChip('None', KeyAnimation.none, theme),
                  const SizedBox(width: 8),
                  _AnimChip('Scale', KeyAnimation.scale, theme),
                  const SizedBox(width: 8),
                  _AnimChip('Ripple', KeyAnimation.ripple, theme),
                  const SizedBox(width: 8),
                  _AnimChip('Bounce', KeyAnimation.bounce, theme),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Layout Tab ───────────────────────────────────────────────────────────────

class _LayoutTab extends StatelessWidget {
  final ThemeProvider theme;
  final Color bg, cardBg, textColor, subColor;
  const _LayoutTab({required this.theme, required this.bg, required this.cardBg, required this.textColor, required this.subColor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Keyboard height
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle('Keyboard Height', textColor),
                  Text('${theme.keyboardHeight.toInt()}px',
                      style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.w600)),
                ],
              ),
              Slider(
                value: theme.keyboardHeight,
                min: 200,
                max: 360,
                divisions: 8,
                activeColor: theme.accentColor,
                onChanged: theme.setKeyboardHeight,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _HeightPreset('Compact', 220, theme),
                  _HeightPreset('Normal', 260, theme),
                  _HeightPreset('Large', 300, theme),
                  _HeightPreset('XL', 340, theme),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // One-handed mode
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('One-Handed Mode', textColor),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ModeChip('Off', theme.oneHandedMode == OneHandedMode.off, theme.accentColor,
                      () => theme.setOneHandedMode(OneHandedMode.off)),
                  const SizedBox(width: 8),
                  _ModeChip('Left', theme.oneHandedMode == OneHandedMode.left, theme.accentColor,
                      () => theme.setOneHandedMode(OneHandedMode.left)),
                  const SizedBox(width: 8),
                  _ModeChip('Right', theme.oneHandedMode == OneHandedMode.right, theme.accentColor,
                      () => theme.setOneHandedMode(OneHandedMode.right)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Toggles
        _SectionCard(
          cardBg: cardBg,
          child: Column(
            children: [
              _ToggleRow('Floating Mode', theme.floatingMode, textColor, theme.accentColor,
                  (v) => theme.setFloatingMode(v)),
              const Divider(height: 1),
              _ToggleRow('Symmetrical Layout', theme.rowStagger, textColor, theme.accentColor,
                  (v) => theme.setRowStagger(v)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  final Color cardBg;
  const _SectionCard({required this.child, required this.cardBg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionTitle(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: color));
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;
  const _ModeChip(this.label, this.selected, this.accentColor, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? accentColor : Colors.grey.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : Colors.grey)),
      ),
    );
  }
}

class _ShapeOption extends StatelessWidget {
  final String label;
  final KeyShape shape;
  final IconData icon;
  final ThemeProvider theme;
  const _ShapeOption(this.label, this.shape, this.icon, this.theme);

  @override
  Widget build(BuildContext context) {
    final selected = theme.keyShape == shape;
    return GestureDetector(
      onTap: () => theme.setKeyShape(shape),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 52,
            height: 40,
            decoration: BoxDecoration(
              color: selected
                  ? theme.accentColor
                  : Colors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(
                  shape == KeyShape.bubble ? 20 : shape == KeyShape.rounded ? 8 : 2),
              border: selected
                  ? null
                  : Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Icon(icon,
                size: 20,
                color: selected ? Colors.white : Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: selected ? theme.accentColor : Colors.grey)),
        ],
      ),
    );
  }
}

class _FeedbackChip extends StatelessWidget {
  final String label;
  final int value;
  final ThemeProvider theme;
  const _FeedbackChip(this.label, this.value, this.theme);

  @override
  Widget build(BuildContext context) {
    final selected = theme.vibrationIntensity == value;
    return GestureDetector(
      onTap: () => theme.setVibrationIntensity(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? theme.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? theme.accentColor : Colors.grey.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : Colors.grey)),
      ),
    );
  }
}

class _SoundChip extends StatelessWidget {
  final String label;
  final SoundTheme value;
  final ThemeProvider theme;
  const _SoundChip(this.label, this.value, this.theme);

  @override
  Widget build(BuildContext context) {
    final selected = theme.soundTheme == value;
    return GestureDetector(
      onTap: () => theme.setSoundTheme(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? theme.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? theme.accentColor : Colors.grey.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : Colors.grey)),
      ),
    );
  }
}

class _AnimChip extends StatelessWidget {
  final String label;
  final KeyAnimation value;
  final ThemeProvider theme;
  const _AnimChip(this.label, this.value, this.theme);

  @override
  Widget build(BuildContext context) {
    final selected = theme.keyAnimation == value;
    return GestureDetector(
      onTap: () => theme.setKeyAnimation(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? theme.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? theme.accentColor : Colors.grey.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : Colors.grey)),
      ),
    );
  }
}

class _HeightPreset extends StatelessWidget {
  final String label;
  final double value;
  final ThemeProvider theme;
  const _HeightPreset(this.label, this.value, this.theme);

  @override
  Widget build(BuildContext context) {
    final selected = (theme.keyboardHeight - value).abs() < 10;
    return GestureDetector(
      onTap: () => theme.setKeyboardHeight(value),
      child: Column(
        children: [
          Container(
            width: 40,
            height: selected ? 28 : 22,
            decoration: BoxDecoration(
              color: selected
                  ? theme.accentColor
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: selected ? theme.accentColor : Colors.grey)),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final Color textColor, accentColor;
  final ValueChanged<bool> onChanged;
  const _ToggleRow(this.label, this.value, this.textColor, this.accentColor, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
          Switch(value: value, activeThumbColor: accentColor, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ─── Mini Keyboard Preview ────────────────────────────────────────────────────

class _MiniKeyboardPreview extends StatelessWidget {
  final ThemeProvider theme;
  const _MiniKeyboardPreview({required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.colorMode == ColorMode.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFD1D5DB);
    final keyColor = isDark ? const Color(0xFF3A3A3C) : Colors.white;
    final actionColor = isDark ? const Color(0xFF545456) : const Color(0xFFADB5BD);
    final textColor = isDark ? Colors.white : Colors.black87;
    final radius = theme.keyBorderRadius.clamp(2.0, 12.0);

    Widget miniKey(String label, {bool isAction = false, double flex = 1}) {
      return Expanded(
        flex: (flex * 10).toInt(),
        child: Container(
          margin: EdgeInsets.all(theme.keyGapSpacing.clamp(1.0, 3.0)),
          height: 28,
          decoration: BoxDecoration(
            color: isAction
                ? (label == '↵' ? theme.accentColor : actionColor)
                : keyColor,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: theme.keyShadow
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 1, offset: const Offset(0, 1))]
                : null,
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: theme.fontWeight,
                    color: isAction ? Colors.white : textColor)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(children: ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'].map((k) => miniKey(k)).toList()),
          Row(children: ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'].map((k) => miniKey(k)).toList()),
          Row(children: [
            miniKey('⇧', isAction: true),
            ...['Z', 'X', 'C', 'V', 'B', 'N', 'M'].map((k) => miniKey(k)),
            miniKey('⌫', isAction: true),
          ]),
          Row(children: [
            miniKey('?123', isAction: true),
            miniKey('space', isAction: false, flex: 3),
            miniKey('↵', isAction: true),
          ]),
        ],
      ),
    );
  }
}
