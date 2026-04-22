import 'package:flutter/material.dart';
import 'keyboard_theme.dart';

/// Samsung-style voice input panel with pulsing mic animation.
class VoicePanel extends StatefulWidget {
  final VoidCallback onCancel;

  const VoicePanel({super.key, required this.onCancel});

  @override
  State<VoicePanel> createState() => _VoicePanelState();
}

class _VoicePanelState extends State<VoicePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = KbColors.of(context);
    return GestureDetector(
      onTap: widget.onCancel,
      child: Container(
        color: colors.keyboardBg,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.accentBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic, size: 36, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Listening...',
                style: TextStyle(fontSize: 14, color: colors.toolbarIcon),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap anywhere to cancel',
                style: TextStyle(fontSize: 12, color: colors.toolbarIcon.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
