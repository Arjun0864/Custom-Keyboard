import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/clipboard_manager.dart';
import '../services/keyboard_service.dart';

class ClipboardPanel extends ConsumerWidget {
  const ClipboardPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clipboardItems = ref.watch(clipboardManagerProvider);
    final keyboardService = ref.watch(keyboardChannelServiceProvider);

    return Container(
      height: 200,
      color: Colors.grey[100],
      child: clipboardItems.isEmpty
          ? const Center(
              child: Text('Clipboard history is empty'),
            )
          : ListView.builder(
              itemCount: clipboardItems.length,
              itemBuilder: (context, index) {
                final item = clipboardItems[index];
                return ListTile(
                  title: Text(
                    item.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    item.timestamp.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    keyboardService.commitText(item.text);
                  },
                  trailing: item.isPinned
                      ? const Icon(Icons.push_pin, color: Colors.blue)
                      : null,
                );
              },
            ),
    );
  }
}
