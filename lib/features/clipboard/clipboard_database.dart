import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'clipboard_model.dart';

/// ClipboardDatabase manages all clipboard history data
///
/// Uses SQLite for persistent storage with sqflite.
/// Features:
/// - Automatic max 20 items limit
/// - Pin/unpin items to prevent deletion
/// - Full CRUD operations
class ClipboardDatabase {
  static const String _databaseName = 'clipboard_history.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'clips';
  static const int _maxItems = 20;

  static final ClipboardDatabase _instance = ClipboardDatabase._internal();

  late Database _database;
  bool _isInitialized = false;

  /// Private constructor for singleton pattern
  ClipboardDatabase._internal();

  /// Get singleton instance
  factory ClipboardDatabase() {
    return _instance;
  }

  /// Get the database instance
  Database get database => _database;

  /// Check if database is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the database
  ///
  /// Must be called before any database operations
  /// Typically called during app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    _isInitialized = true;
  }

  /// Create database table on first run
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        is_pinned INTEGER DEFAULT 0
      )
    ''');

    // Create an index on timestamp for faster sorting
    await db.execute('''
      CREATE INDEX idx_timestamp ON $_tableName(timestamp DESC)
    ''');
  }

  /// Handle database version upgrades
  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Future upgrade path
    // Currently just keep the old table
  }

  /// Save a clipboard item to the database
  ///
  /// Automatically handles max items limit by deleting oldest unpinned items
  /// Returns the new clip item with its ID
  Future<ClipItem> saveClip(String text) async {
    if (!_isInitialized) return ClipItem(text: text, timestamp: DateTime.now());

    final now = DateTime.now();
    final clip = ClipItem(
      text: text,
      timestamp: now,
      isPinned: false,
    );

    try {
      // Insert the new clip
      final id = await _database.insert(
        _tableName,
        clip.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Check if we've exceeded max items
      await _enforceMaxItems();

      return clip.copyWith(id: id);
    } catch (e) {
      print('Error saving clip: $e');
      rethrow;
    }
  }

  /// Get all clipboard items, ordered by timestamp (newest first)
  ///
  /// Pinned items appear at the top, followed by recent items
  Future<List<ClipItem>> getAllClips() async {
    if (!_isInitialized) return [];

    try {
      final maps = await _database.query(
        _tableName,
        orderBy: 'is_pinned DESC, timestamp DESC',
      );

      return List<ClipItem>.from(
        maps.map((map) => ClipItem.fromMap(map)),
      );
    } catch (e) {
      print('Error getting all clips: $e');
      return [];
    }
  }

  /// Get a specific clip by ID
  Future<ClipItem?> getClipById(int id) async {
    if (!_isInitialized) return null;

    try {
      final maps = await _database.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return ClipItem.fromMap(maps.first);
    } catch (e) {
      print('Error getting clip by ID: $e');
      return null;
    }
  }

  /// Get recent clips (last N items)
  Future<List<ClipItem>> getRecentClips({int limit = 10}) async {
    if (!_isInitialized) return [];

    try {
      final maps = await _database.query(
        _tableName,
        orderBy: 'is_pinned DESC, timestamp DESC',
        limit: limit,
      );

      return List<ClipItem>.from(
        maps.map((map) => ClipItem.fromMap(map)),
      );
    } catch (e) {
      print('Error getting recent clips: $e');
      return [];
    }
  }

  /// Pin a clipboard item (prevents auto-deletion)
  Future<bool> pinClip(int id) async {
    if (!_isInitialized) return false;

    try {
      final result = await _database.update(
        _tableName,
        {'is_pinned': 1},
        where: 'id = ?',
        whereArgs: [id],
      );

      return result > 0;
    } catch (e) {
      print('Error pinning clip: $e');
      return false;
    }
  }

  /// Unpin a clipboard item
  Future<bool> unpinClip(int id) async {
    if (!_isInitialized) return false;

    try {
      final result = await _database.update(
        _tableName,
        {'is_pinned': 0},
        where: 'id = ?',
        whereArgs: [id],
      );

      return result > 0;
    } catch (e) {
      print('Error unpinning clip: $e');
      return false;
    }
  }

  /// Toggle pin status of a clip
  Future<bool> togglePin(int id) async {
    if (!_isInitialized) return false;

    try {
      final clip = await getClipById(id);
      if (clip == null) return false;

      return clip.isPinned ? unpinClip(id) : pinClip(id);
    } catch (e) {
      print('Error toggling pin: $e');
      return false;
    }
  }

  /// Delete a specific clip by ID
  Future<bool> deleteClip(int id) async {
    if (!_isInitialized) return false;

    try {
      final result = await _database.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return result > 0;
    } catch (e) {
      print('Error deleting clip: $e');
      return false;
    }
  }

  /// Delete multiple clips by ID
  Future<bool> deleteClips(List<int> ids) async {
    if (!_isInitialized) return false;
    if (ids.isEmpty) return true;

    try {
      final placeholders = List.filled(ids.length, '?').join(',');
      final result = await _database.delete(
        _tableName,
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );

      return result > 0;
    } catch (e) {
      print('Error deleting multiple clips: $e');
      return false;
    }
  }

  /// Delete all unpinned clips
  Future<bool> deleteAllUnpinned() async {
    if (!_isInitialized) return false;

    try {
      final result = await _database.delete(
        _tableName,
        where: 'is_pinned = 0',
      );

      return result >= 0;
    } catch (e) {
      print('Error deleting unpinned clips: $e');
      return false;
    }
  }

  /// Clear all clipboard history
  ///
  /// WARNING: This deletes all clips, including pinned ones
  Future<bool> clearAll() async {
    if (!_isInitialized) return false;

    try {
      await _database.delete(_tableName);
      return true;
    } catch (e) {
      print('Error clearing all clips: $e');
      return false;
    }
  }

  /// Get total number of clips
  Future<int> getClipCount() async {
    if (!_isInitialized) return 0;

    try {
      final result = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName',
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error getting clip count: $e');
      return 0;
    }
  }

  /// Get number of pinned clips
  Future<int> getPinnedCount() async {
    if (!_isInitialized) return 0;

    try {
      final result = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE is_pinned = 1',
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error getting pinned count: $e');
      return 0;
    }
  }

  /// Enforce maximum items limit
  ///
  /// If total items exceed _maxItems, oldest unpinned items are deleted
  /// Pinned items are never deleted by this function
  Future<void> _enforceMaxItems() async {
    try {
      final count = await getClipCount();

      if (count > _maxItems) {
        // Calculate how many items to delete
        final toDelete = count - _maxItems;

        // Delete oldest unpinned items
        final oldestItems = await _database.query(
          _tableName,
          where: 'is_pinned = 0',
          orderBy: 'timestamp ASC',
          limit: toDelete,
        );

        if (oldestItems.isNotEmpty) {
          final ids =
              oldestItems.map((item) => item['id'] as int).toList();
          await deleteClips(ids);
        }
      }
    } catch (e) {
      print('Error enforcing max items: $e');
    }
  }

  /// Search clips by text content
  ///
  /// Case-insensitive substring search
  Future<List<ClipItem>> searchClips(String query) async {
    if (!_isInitialized) return [];
    if (query.isEmpty) return getAllClips();

    try {
      final maps = await _database.query(
        _tableName,
        where: 'LOWER(text) LIKE ?',
        whereArgs: ['%${query.toLowerCase()}%'],
        orderBy: 'is_pinned DESC, timestamp DESC',
      );

      return List<ClipItem>.from(
        maps.map((map) => ClipItem.fromMap(map)),
      );
    } catch (e) {
      print('Error searching clips: $e');
      return [];
    }
  }

  /// Duplicate a clip (create a new copy)
  ///
  /// Useful for when user wants to paste the same text again
  Future<ClipItem?> duplicateClip(int id) async {
    final clip = await getClipById(id);
    if (clip == null) return null;

    return saveClip(clip.text);
  }

  /// Export all clips as a list (for backup)
  Future<List<Map<String, dynamic>>> exportAll() async {
    if (!_isInitialized) return [];

    try {
      return await _database.query(_tableName);
    } catch (e) {
      print('Error exporting clips: $e');
      return [];
    }
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      return {
        'total': await getClipCount(),
        'pinned': await getPinnedCount(),
        'maxItems': _maxItems,
        'databasePath': _database.path,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }

  /// Close the database
  ///
  /// Call this when the app is shutting down
  Future<void> close() async {
    if (_isInitialized) {
      await _database.close();
      _isInitialized = false;
    }
  }
}
