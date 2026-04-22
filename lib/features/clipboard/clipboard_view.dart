import 'package:flutter/material.dart';
import 'clipboard_model.dart';
import 'clipboard_database.dart';

/// ClipboardView displays recent clipboard items in a horizontal scrollable list
///
/// Features:
/// - Horizontal scrollable list of clips
/// - Tap to paste
/// - Long press for options (pin/delete)
/// - Pin indicator icon
/// - Shows time since added
/// - Appears above keyboard keys
class ClipboardView extends StatefulWidget {
  /// Callback when a clipboard item is selected (to paste)
  final Function(String)? onClipSelected;

  /// Callback when a clip is deleted
  final VoidCallback? onClipDeleted;

  /// Callback when a clip is pinned/unpinned
  final VoidCallback? onClipPinned;

  /// Maximum number of clips to display
  final int maxDisplayItems;

  /// Height of the clipboard view
  final double height;

  /// Whether to show the view
  final bool isVisible;

  /// Animation duration
  final Duration animationDuration;

  const ClipboardView({
    super.key,
    this.onClipSelected,
    this.onClipDeleted,
    this.onClipPinned,
    this.maxDisplayItems = 10,
    this.height = 80,
    this.isVisible = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<ClipboardView> createState() => _ClipboardViewState();
}

class _ClipboardViewState extends State<ClipboardView>
    with SingleTickerProviderStateMixin {
  final ClipboardDatabase _clipboard = ClipboardDatabase();
  List<ClipItem> _clips = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _loadClips();
    _setupAutoRefresh();

    // Auto-expand on init
    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ClipboardView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isVisible != widget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
        _loadClips();
      } else {
        _animationController.reverse();
      }
    }
  }

  /// Load clips from database
  Future<void> _loadClips() async {
    try {
      final clips = await _clipboard.getRecentClips(
        limit: widget.maxDisplayItems,
      );

      setState(() {
        _clips = clips;
      });
    } catch (e) {
      debugPrint('Error loading clips: $e');
    }
  }

  /// Setup periodic refresh to update timestamps
  void _setupAutoRefresh() {
    // Refresh every 30 seconds to update "time ago" text
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadClips();
        _setupAutoRefresh();
      }
    });
  }

  /// Handle tap on a clip item
  void _handleClipTap(ClipItem clip) {
    if (clip.id == null) return;

    // Callback to paste the text
    widget.onClipSelected?.call(clip.text);

    // Optional: Visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pasted: ${clip.getPreview(maxLength: 40)}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Handle long press on a clip item
  void _handleClipLongPress(ClipItem clip) {
    if (clip.id == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => _buildClipOptionsMenu(clip),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    );
  }

  /// Build options menu for clip
  Widget _buildClipOptionsMenu(ClipItem clip) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Clip preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              clip.getPreview(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const Divider(),

          // Pin/Unpin option
          ListTile(
            leading: Icon(
              clip.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: Colors.blue,
            ),
            title: Text(clip.isPinned ? 'Unpin' : 'Pin'),
            onTap: () {
              _togglePin(clip.id!);
              Navigator.pop(context);
            },
          ),

          // Copy option
          ListTile(
            leading: const Icon(Icons.content_copy, color: Colors.green),
            title: const Text('Copy'),
            onTap: () {
              // Show message that it's already copied
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Already copied to clipboard'),
                  duration: Duration(milliseconds: 500),
                ),
              );
            },
          ),

          // Delete option
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete'),
            onTap: () {
              _deleteClip(clip.id!);
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Toggle pin status
  Future<void> _togglePin(int id) async {
    await _clipboard.togglePin(id);
    widget.onClipPinned?.call();
    _loadClips();
  }

  /// Delete a clip
  Future<void> _deleteClip(int id) async {
    await _clipboard.deleteClip(id);
    widget.onClipDeleted?.call();
    _loadClips();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clip deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      ),
      child: Container(
        width: double.infinity,
        height: widget.height,
        color: Colors.grey[100],
        child: _clips.isEmpty
            ? _buildEmptyState()
            : _buildClipsList(),
      ),
    );
  }

  /// Build empty state when no clips
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.content_paste_off,
            size: 32,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No clips yet',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Build horizontal scrollable list of clips
  Widget _buildClipsList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: _clips.length,
      itemBuilder: (context, index) {
        return _buildClipCard(_clips[index]);
      },
    );
  }

  /// Build a single clip card
  Widget _buildClipCard(ClipItem clip) {
    return GestureDetector(
      onTap: () => _handleClipTap(clip),
      onLongPress: () => _handleClipLongPress(clip),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            width: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.blue.shade100,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with pin icon
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          clip.getFormattedTime(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (clip.isPinned)
                        Icon(
                          Icons.push_pin,
                          size: 14,
                          color: Colors.blue.shade600,
                        ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 1,
                  color: Colors.blue.shade200,
                ),

                // Clip text preview
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      clip.getPreview(maxLength: 60),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),

                // Footer with indicator
                Container(
                  height: 3,
                  color: Colors.blue.shade200,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

/// Simplified compact version of ClipboardView for minimal space
class CompactClipboardView extends StatelessWidget {
  final List<ClipItem> clips;
  final Function(String)? onClipSelected;
  final VoidCallback? onShowFull;

  const CompactClipboardView({
    super.key,
    required this.clips,
    this.onClipSelected,
    this.onShowFull,
  });

  @override
  Widget build(BuildContext context) {
    if (clips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      color: Colors.grey[200],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        itemCount: clips.length + 1,
        itemBuilder: (context, index) {
          if (index == clips.length) {
            // Show "more" button
            return GestureDetector(
              onTap: onShowFull,
              child: Container(
                margin: const EdgeInsets.all(2),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '+${clips.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }

          return _buildCompactClipItem(clips[index]);
        },
      ),
    );
  }

  Widget _buildCompactClipItem(ClipItem clip) {
    return GestureDetector(
      onTap: () => onClipSelected?.call(clip.text),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: clip.isPinned ? Colors.blue.shade100 : Colors.white,
          border: Border.all(
            color: clip.isPinned ? Colors.blue.shade300 : Colors.grey.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            clip.getPreview(maxLength: 20),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[800],
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
