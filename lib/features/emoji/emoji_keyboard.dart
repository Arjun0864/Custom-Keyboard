import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../keyboard/keyboard_controller.dart';

/// Represents emoji categories
enum EmojiCategory {
  recent,
  smileys,
  people,
  animals,
  food,
  travel,
  objects,
  symbols,
}

/// Emoji data storage with categorized emojis
class EmojiData {
  static const Map<String, List<String>> emojisByCategory = {
    'recent': [],
    'smileys': [
      '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂',
      '🙂', '🙃', '😉', '😊', '😇', '😍', '🥰', '😘',
      '😗', '😚', '😙', '🥲', '😋', '😛', '😜', '🤪',
      '😌', '😔', '😑', '😐', '😶', '🤫', '🤭', '🤫',
      '😏', '😒', '🙄', '😬', '🤥', '😌', '😔', '😪',
      '🤤', '😴', '😷', '🤒', '🤕', '🤮', '🤢', '🤮',
      '🤮', '🤮', '🤮', '🤮', '🤮', '🤮', '🤮', '🤮',
    ],
    'people': [
      '👋', '🤚', '🖐️', '✋', '🖖', '👌', '🤌', '🤏',
      '✌️', '🤞', '🫰', '🤟', '🤘', '🤙', '👍', '👎',
      '👊', '👏', '🙌', '👐', '🫲', '🫳', '🤲', '🤝',
      '🤜', '🤛', '🦵', '🦶', '👂', '👃', '🧠', '🦷',
      '🦴', '👀', '👁️', '👅', '👄', '🐶', '🐱', '🐭',
      '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁',
      '🐮', '🐷', '🐽', '🐸', '🐵', '🙈', '🙉', '🙊',
    ],
    'animals': [
      '🐒', '🐔', '🐧', '🐦', '🐤', '🐣', '🐥', '🦆',
      '🦅', '🦉', '🦇', '🐺', '🐗', '🐴', '🦄', '🐝',
      '🪱', '🐛', '🦋', '🐌', '🐞', '🐜', '🪰', '🪲',
      '🦗', '🕷️', '🦂', '🐢', '🐍', '🦎', '🦖', '🦕',
      '🐙', '🦑', '🦐', '🦞', '🦟', '🦠', '🐡', '🐠',
      '🐟', '🐬', '🐳', '🐋', '🦈', '🐊', '🐅', '🐆',
      '🦓', '🦍', '🦧', '🐘', '🦛', '🦏', '🐪', '🐫',
    ],
    'food': [
      '🍏', '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇',
      '🍓', '🫐', '🍈', '🍒', '🍑', '🥭', '🍍', '🥥',
      '🥑', '🍆', '🍅', '🌶️', '🌽', '🥒', '🥬', '🥦',
      '🧄', '🧅', '🍄', '🥜', '🌰', '🍞', '🥐', '🥯',
      '🥖', '🥨', '🧀', '🥚', '🍳', '🧈', '🥞', '🥓',
      '🥞', '🥪', '🌭', '🍔', '🍟', '🍗', '🍖', '🌮',
      '🌯', '🥙', '🧆', '🥘', '🥫', '🍝', '🍜', '🍲',
    ],
    'travel': [
      '🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑',
      '🚒', '🚐', '🛻', '🚚', '🚛', '🚜', '🏍️', '🏎️',
      '🛵', '🦯', '🛺', '🚲', '🛴', '🛹', '🛼', '🛽',
      '🚨', '🚔', '🚍', '🚘', '🚖', '🚡', '🚠', '🚟',
      '🚃', '🚋', '🚞', '🚝', '🚄', '🚅', '🚈', '�2️',
      '🚆', '🚇', '🚊', '⛴️', '🛳️', '🛶', '⛵', '🚤',
      '🛥️', '🛩️', '✈️', '🛫', '🛬', '🪂', '💺', '🚁',
    ],
    'objects': [
      '⌚', '📱', '📲', '💻', '⌨️', '🖥️', '🖨️', '🖱️',
      '🖲️', '🕹️', '🗜️', '💽', '💾', '💿', '📀', '🧮',
      '🎥', '🎬', '📺', '📷', '📸', '📹', '🎞️', '📽️',
      '🎦', '📞', '☎️', '📟', '📠', '📺', '📻', '🎙️',
      '🎚️', '🎛️', '🧭', '⏱️', '⏲️', '⏰', '🕰️', '⌛',
      '⏳', '📡', '🔋', '🔌', '💡', '🔦', '🕯️', '💸',
      '💵', '💴', '💶', '💷', '💰', '💳', '🧾', '✉️',
    ],
    'symbols': [
      '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
      '🤎', '🖤', '💔', '💕', '💞', '💓', '💗', '💖',
      '💘', '💝', '💟', '👋', '✋', '🖐️', '✌️', '🤞',
      '🫰', '🤟', '🤘', '🤙', '👍', '👎', '👊', '👏',
      '🙌', '👐', '🤲', '🤝', '🙏', '✍️', '💅', '🤳',
      '💪', '🦵', '🦶', '👂', '👃', '🧠', '🦷', '🦴',
      '👀', '👁️', '👅', '👄', '🔥', '✨', '⭐', '🌟',
    ],
  };

  /// Get emoji list by category
  static List<String> getEmojisByCategory(String category) {
    return emojisByCategory[category] ?? [];
  }

  /// Get all emojis grouped by category
  static List<String> getAllEmojis() {
    final allEmojis = <String>[];
    emojisByCategory.forEach((_, emojis) {
      allEmojis.addAll(emojis);
    });
    return allEmojis;
  }
}

/// Emoji keyboard widget with categories, search, and recent emojis
class EmojiKeyboard extends StatefulWidget {
  final KeyboardController? keyboardController;
  final VoidCallback onBack;
  final double height;

  const EmojiKeyboard({
    Key? key,
    this.keyboardController,
    required this.onBack,
    this.height = 300,
  }) : super(key: key);

  @override
  State<EmojiKeyboard> createState() => _EmojiKeyboardState();
}

class _EmojiKeyboardState extends State<EmojiKeyboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  late SharedPreferences _prefs;
  List<String> _recentEmojis = [];
  String _searchQuery = '';

  static const String _recentEmojisKey = 'recentEmojis';
  static const int _maxRecentEmojis = 24;

  final List<EmojiCategory> _categories = [
    EmojiCategory.recent,
    EmojiCategory.smileys,
    EmojiCategory.people,
    EmojiCategory.animals,
    EmojiCategory.food,
    EmojiCategory.travel,
    EmojiCategory.objects,
    EmojiCategory.symbols,
  ];

  final List<IconData> _categoryIcons = [
    Icons.schedule,
    Icons.sentiment_satisfied,
    Icons.people,
    Icons.pets,
    Icons.restaurant,
    Icons.flight,
    Icons.lightbulb,
    Icons.star,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _loadRecentEmojis();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Load recent emojis from SharedPreferences
  Future<void> _loadRecentEmojis() async {
    _prefs = await SharedPreferences.getInstance();
    final recentStr = _prefs.getString(_recentEmojisKey) ?? '';
    setState(() {
      _recentEmojis = recentStr.isEmpty
          ? []
          : recentStr.split(',').where((e) => e.isNotEmpty).toList();
    });
  }

  /// Save emoji to recent list
  Future<void> _addToRecent(String emoji) async {
    setState(() {
      _recentEmojis.removeWhere((e) => e == emoji);
      _recentEmojis.insert(0, emoji);
      if (_recentEmojis.length > _maxRecentEmojis) {
        _recentEmojis = _recentEmojis.sublist(0, _maxRecentEmojis);
      }
    });

    await _prefs.setString(_recentEmojisKey, _recentEmojis.join(','));
  }

  /// Handle emoji selection
  void _onEmojiTapped(String emoji) {
    _addToRecent(emoji);
    widget.keyboardController?.insertCharacter(emoji);
  }

  /// Handle search query changes
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header with back button and search
          _buildHeader(),

          // Category tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: List.generate(
              _categories.length,
              (index) => Tab(
                icon: Icon(_categoryIcons[index], size: 20),
              ),
            ),
          ),

          // Emoji grid or search results
          Expanded(
            child: _searchQuery.isEmpty
                ? TabBarView(
                    controller: _tabController,
                    children: List.generate(
                      _categories.length,
                      (index) => _buildEmojiGrid(
                        _categories[index],
                      ),
                    ),
                  )
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  /// Build header with back button and search
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
            tooltip: 'Back to keyboard',
          ),

          // Search bar
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  border: InputBorder.none,
                  hintText: 'Search emoji...',
                  suffixIcon: _searchQuery.isEmpty
                      ? const Icon(Icons.search, size: 20)
                      : GestureDetector(
                          onTap: () {
                            _searchController.clear();
                          },
                          child: const Icon(Icons.clear, size: 20),
                        ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),
    );
  }

  /// Build emoji grid for a specific category
  Widget _buildEmojiGrid(EmojiCategory category) {
    List<String> emojis;

    if (category == EmojiCategory.recent) {
      emojis = _recentEmojis;
    } else {
      emojis = EmojiData.getEmojisByCategory(category.toString().split('.').last);
    }

    if (emojis.isEmpty) {
      return Center(
        child: Text(
          category == EmojiCategory.recent
              ? 'No recent emojis'
              : 'No emojis found',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: emojis.length,
      itemBuilder: (context, index) {
        final emoji = emojis[index];
        return _buildEmojiButton(emoji);
      },
    );
  }

  /// Build search results grid
  Widget _buildSearchResults() {
    final allEmojis = EmojiData.getAllEmojis();
    final results = allEmojis
        .where(
          (emoji) => emoji.toLowerCase().contains(_searchQuery),
        )
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No emojis found for "$_searchQuery"',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildEmojiButton(results[index]);
      },
    );
  }

  /// Build individual emoji button
  Widget _buildEmojiButton(String emoji) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onEmojiTapped(emoji),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

/// Widget for displaying emoji keyboard in a bottom sheet
class EmojiKeyboardBottomSheet extends StatelessWidget {
  final KeyboardController? keyboardController;
  final double height;

  const EmojiKeyboardBottomSheet({
    super.key,
    this.keyboardController,
    this.height = 400,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: EmojiKeyboard(
        keyboardController: keyboardController,
        onBack: () => Navigator.pop(context),
        height: height - 16,
      ),
    );
  }
}
