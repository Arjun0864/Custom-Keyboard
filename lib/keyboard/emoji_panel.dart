import 'package:flutter/material.dart';
import 'keyboard_theme.dart';
import 'keyboard_controller.dart';

/// Samsung-style emoji panel — tabs + 8-per-row grid, same height as keyboard.
class EmojiPanel extends StatefulWidget {
  final KeyboardController controller;

  const EmojiPanel({super.key, required this.controller});

  @override
  State<EmojiPanel> createState() => _EmojiPanelState();
}

class _EmojiPanelState extends State<EmojiPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _tabs = ['🕐','😀','👋','🐶','🍕','⚽','💡','❤️'];

  static const _recent = <String>[];

  static const _smileys = [
    '😀','😃','😄','😁','😆','😅','🤣','😂','🙂','🙃','😉','😊','😇',
    '🥰','😍','🤩','😘','😗','😚','😙','🥲','😋','😛','😜','🤪','😝',
    '🤑','🤗','🤭','🤫','🤔','🤐','🤨','😐','😑','😶','😏','😒','🙄',
    '😬','🤥','😌','😔','😪','🤤','😴','😷','🤒','🤕','🤢','🤮','🤧',
    '🥵','🥶','🥴','😵','🤯','🤠','🥳','🥸','😎','🤓','🧐','😕','😟',
    '🙁','☹️','😮','😯','😲','😳','🥺','😦','😧','😨','😰','😥','😢',
    '😭','😱','😖','😣','😞','😓','😩','😫','🥱','😤','😡','😠','🤬',
  ];

  static const _people = [
    '👋','🤚','🖐','✋','🖖','👌','🤌','🤏','✌','🤞','🤟','🤘','🤙',
    '👈','👉','👆','🖕','👇','☝','👍','👎','✊','👊','🤛','🤜','👏',
    '🙌','👐','🤲','🤝','🙏','✍','💅','🤳','💪','🦾','🦵','🦶','👂',
    '🦻','👃','🧠','🦷','🦴','👀','👁','👅','👄','💋','🩸','👶','🧒',
    '👦','👧','🧑','👱','👨','🧔','👩','🧓','👴','👵','🙍','🙎','🙅',
    '🙆','💁','🙋','🧏','🙇','🤦','🤷','👮','🕵','💂','🥷','👷','🤴',
  ];

  static const _animals = [
    '🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯','🦁','🐮','🐷',
    '🐸','🐵','🙈','🙉','🙊','🐔','🐧','🐦','🐤','🦆','🦅','🦉','🦇',
    '🐺','🐗','🐴','🦄','🐝','🐛','🦋','🐌','🐞','🐜','🦟','🦗','🕷',
    '🦂','🐢','🐍','🦎','🦖','🦕','🐙','🦑','🦐','🦞','🦀','🐡','🐠',
    '🐟','🐬','🐳','🐋','🦈','🐊','🐅','🐆','🦓','🦍','🦧','🦣','🐘',
  ];

  static const _food = [
    '🍎','🍐','🍊','🍋','🍌','🍉','🍇','🍓','🫐','🍈','🍒','🍑','🥭',
    '🍍','🥥','🥝','🍅','🍆','🥑','🥦','🥬','🥒','🌶','🫑','🧄','🧅',
    '🥔','🍠','🥐','🥯','🍞','🥖','🥨','🧀','🥚','🍳','🧈','🥞','🧇',
    '🥓','🥩','🍗','🍖','🌭','🍔','🍟','🍕','🫓','🥪','🥙','🧆','🌮',
    '🌯','🫔','🥗','🥘','🫕','🥫','🍝','🍜','🍲','🍛','🍣','🍱','🥟',
    '🍤','🍙','🍚','🍘','🍥','🥮','🍢','🧁','🍰','🎂','🍮','🍭','🍬',
  ];

  static const _sports = [
    '⚽','🏀','🏈','⚾','🥎','🎾','🏐','🏉','🥏','🎱','🪀','🏓','🏸',
    '🏒','🏑','🥍','🏏','🪃','🥅','⛳','🪁','🏹','🎣','🤿','🥊','🥋',
    '🎽','🛹','🛼','🛷','⛸','🥌','🎿','⛷','🏂','🪂','🏋','🤼','🤸',
    '⛹','🤺','🏇','🧘','🏄','🏊','🤽','🚣','🧗','🚵','🚴','🏆','🥇',
    '🥈','🥉','🏅','🎖','🏵','🎗','🎫','🎟','🎪','🤹','🎭','🩰','🎨',
  ];

  static const _objects = [
    '💡','🔦','🕯','🪔','🧯','🛢','💸','💵','💴','💶','💷','🪙','💰',
    '💳','💎','⚖','🪜','🧰','🪛','🔧','🔨','⚒','🛠','⛏','🪚','🔩',
    '🪤','🧲','🔫','💣','🪓','🔪','🗡','⚔','🛡','🪃','🏹','🪝','🧱',
    '🪞','🪟','🛏','🛋','🪑','🚽','🪠','🚿','🛁','🪤','🧴','🧷','🧹',
    '🧺','🧻','🪣','🧼','🫧','🪥','🧽','🛒','🚪','📱','💻','⌨','🖥',
    '🖨','🖱','🖲','🕹','🗜','💽','💾','💿','📀','📼','📷','📸','📹',
  ];

  static const _symbols = [
    '❤','🧡','💛','💚','💙','💜','🖤','🤍','🤎','💔','❤‍🔥','❤‍🩹',
    '❣','💕','💞','💓','💗','💖','💘','💝','💟','☮','✝','☪','🕉',
    '☸','✡','🔯','🕎','☯','☦','🛐','⛎','♈','♉','♊','♋','♌',
    '♍','♎','♏','♐','♑','♒','♓','🆔','⚛','🉑','☢','☣','📴',
    '📳','🈶','🈚','🈸','🈺','🈷','✴','🆚','💮','🉐','㊙','㊗','🈴',
    '🈵','🈹','🈲','🅰','🅱','🆎','🆑','🅾','🆘','❌','⭕','🛑','⛔',
  ];

  static const _allEmojis = [
    _recent, _smileys, _people, _animals, _food, _sports, _objects, _symbols,
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = KbColors.of(context);
    return Column(
      children: [
        // Tab bar
        Container(
          height: 40,
          color: colors.keyboardBg,
          child: TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            indicatorColor: colors.accentBlue,
            indicatorWeight: 2,
            labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            tabs: _tabs.map((t) => Tab(
              child: Text(t, style: const TextStyle(fontSize: 18)),
            )).toList(),
          ),
        ),
        // Grid
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: List.generate(_tabs.length, (i) {
              final emojis = _allEmojis[i];
              if (emojis.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 40, color: colors.toolbarIcon),
                      const SizedBox(height: 8),
                      Text('No recent emojis',
                          style: TextStyle(color: colors.toolbarIcon, fontSize: 13)),
                    ],
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  childAspectRatio: 1,
                ),
                itemCount: emojis.length,
                itemBuilder: (_, idx) => GestureDetector(
                  onTap: () => widget.controller.insertCharacter(emojis[idx]),
                  child: Center(
                    child: Text(emojis[idx], style: const TextStyle(fontSize: 28)),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
