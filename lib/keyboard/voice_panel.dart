import 'package:flutter/material.dart';
import 'keyboard_theme.dart';

class VoicePanel extends StatefulWidget {
  final VoidCallback onCancel;
  const VoicePanel({super.key, required this.onCancel});
  @override
  State<VoicePanel> createState() => _VoicePanelState();
}

class _VoicePanelState extends State<VoicePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = KbTheme.of(context);
    return GestureDetector(
      onTap: widget.onCancel,
      child: Container(
        color: t.bg,
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 68, height: 68,
              decoration: const BoxDecoration(
                color: Color(0xFF007AFF), shape: BoxShape.circle),
              child: const Icon(Icons.mic, size: 34, color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Text('Listening...', style: TextStyle(fontSize: 14, color: t.toolbarIcon)),
          const SizedBox(height: 6),
          Text('Tap to cancel',
            style: TextStyle(fontSize: 12, color: t.toolbarIcon.withValues(alpha: 0.6))),
        ])),
      ),
    );
  }
}
