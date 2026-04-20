/// ClipItem model represents a single clipboard item
///
/// Stores:
/// - id: Unique identifier
/// - text: The clipboard content
/// - timestamp: When the item was added
/// - isPinned: Whether the item should remain in history
class ClipItem {
  /// Unique identifier for the clip
  final int? id;

  /// The text content of the clipboard item
  final String text;

  /// When this item was added to clipboard history
  final DateTime timestamp;

  /// Whether this item is pinned and should not be auto-deleted
  final bool isPinned;

  const ClipItem({
    this.id,
    required this.text,
    required this.timestamp,
    this.isPinned = false,
  });

  /// Create a copy of ClipItem with some fields overridden
  ClipItem copyWith({
    int? id,
    String? text,
    DateTime? timestamp,
    bool? isPinned,
  }) {
    return ClipItem(
      id: id ?? this.id,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  /// Convert ClipItem to a JSON map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_pinned': isPinned ? 1 : 0,
    };
  }

  /// Create ClipItem from database map
  factory ClipItem.fromMap(Map<String, dynamic> map) {
    return ClipItem(
      id: map['id'] as int,
      text: map['text'] as String,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      isPinned: (map['is_pinned'] as int) == 1,
    );
  }

  /// Get a preview of the text (first 50 chars)
  String getPreview({int maxLength = 50}) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  /// Format timestamp as readable string
  String getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }

  /// Check if text is truncated in preview
  bool isPreviewTruncated({int maxLength = 50}) {
    return text.length > maxLength;
  }

  @override
  String toString() => 'ClipItem(id: $id, text: ${getPreview()}, time: ${getFormattedTime()}, pinned: $isPinned)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          timestamp == other.timestamp &&
          isPinned == other.isPinned;

  @override
  int get hashCode =>
      id.hashCode ^ text.hashCode ^ timestamp.hashCode ^ isPinned.hashCode;
}
