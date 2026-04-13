import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_constants.dart';

/// Enable Keyboard Setup Screen
/// Shows instructions for enabling FlutterBoard keyboard
class EnableKeyboardScreen extends ConsumerStatefulWidget {
  const EnableKeyboardScreen({super.key});

  @override
  ConsumerState<EnableKeyboardScreen> createState() => _EnableKeyboardScreenState();
}

class _EnableKeyboardScreenState extends ConsumerState<EnableKeyboardScreen> {
  final _methodChannel = const MethodChannel(AppConstants.methodChannel);
  bool _isKeyboardEnabled = false;
  bool _isDefaultKeyboard = false;

  @override
  void initState() {
    super.initState();
    _checkKeyboardStatus();
  }

  Future<void> _checkKeyboardStatus() async {
    try {
      final isEnabled = await _methodChannel.invokeMethod<bool>('isKeyboardEnabled');
      final isDefault = await _methodChannel.invokeMethod<bool>('isDefaultKeyboard');
      
      setState(() {
        _isKeyboardEnabled = isEnabled ?? false;
        _isDefaultKeyboard = isDefault ?? false;
      });
    } catch (e) {
      debugPrint('Error checking keyboard status: $e');
    }
  }

  Future<void> _goToKeyboardSettings() async {
    try {
      await _methodChannel.invokeMethod('openKeyboardSettings');
    } catch (e) {
      debugPrint('Error opening keyboard settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enable FlutterBoard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
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

              // Title
              Text(
                'Setup FlutterBoard Keyboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'Follow these steps to enable and use FlutterBoard as your system keyboard.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Step 1: Enable Keyboard
              _buildStepCard(
                context,
                step: 1,
                title: 'Enable FlutterBoard',
                description: 'Go to Settings > Language & input > Virtual keyboard > Manage keyboards',
                completed: _isKeyboardEnabled,
                action: 'Open Settings',
                onTap: _goToKeyboardSettings,
              ),
              const SizedBox(height: 16),

              // Step 2: Set as Default
              _buildStepCard(
                context,
                step: 2,
                title: 'Set as Default Keyboard',
                description: 'Select FlutterBoard as your default input method',
                completed: _isDefaultKeyboard,
                action: 'Set Default',
                onTap: _goToKeyboardSettings,
              ),
              const SizedBox(height: 16),

              // Step 3: Start Using
              _buildStepCard(
                context,
                step: 3,
                title: 'Start Typing',
                description: 'Open any text field to start using FlutterBoard',
                completed: _isKeyboardEnabled && _isDefaultKeyboard,
              ),
              const SizedBox(height: 32),

              // Features Section
              Text(
                'Features',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildFeatureItem(
                icon: Icons.lightbulb_outline,
                title: 'Smart Suggestions',
                description: 'Get intelligent word suggestions as you type',
              ),
              const SizedBox(height: 12),

              _buildFeatureItem(
                icon: Icons.emoji_emotions_outlined,
                title: 'Emoji Support',
                description: 'Easy access to thousands of emojis',
              ),
              const SizedBox(height: 12),

              _buildFeatureItem(
                icon: Icons.content_copy_outlined,
                title: 'Clipboard Manager',
                description: 'Quick access to clipboard history',
              ),
              const SizedBox(height: 12),

              _buildFeatureItem(
                icon: Icons.translate,
                title: 'Multi-Language',
                description: 'Support for 13+ languages',
              ),
              const SizedBox(height: 12),

              _buildFeatureItem(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                description: 'Beautiful dark theme for night typing',
              ),
              const SizedBox(height: 12),

              _buildFeatureItem(
                icon: Icons.tune_outlined,
                title: 'Customizable',
                description: 'Adjust spacing, colors, and layout',
              ),
              const SizedBox(height: 32),

              // Status Section
              if (_isKeyboardEnabled)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keyboard Enabled',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isDefaultKeyboard 
                                ? 'FlutterBoard is your default keyboard'
                                : 'Open Settings to set as default',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required int step,
    required String title,
    required String description,
    required bool completed,
    String? action,
    VoidCallback? onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: completed ? Colors.green : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number or checkmark
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? Colors.green : Colors.blue,
            ),
            child: Center(
              child: completed
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                  step.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (action != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(action),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
