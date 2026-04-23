import 'package:flutter/material.dart';
import 'keyboard_theme.dart';
import 'keyboard_controller.dart';

class EmojiPanel extends StatefulWidget {
  final KeyboardController controller;
  const EmojiPanel({super.key, required this.controller});
  @override
  State<EmojiPanel> createState() => _EmojiPanelState();
}

class _EmojiPanelState extends State<EmojiPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const _tabs   = ['🕐','😀','👋','🐶','🍕','⚽','💡','❤️'];
  static const _recent = <String>[];
  static const _smileys = ['😀','😃','😄','😁','😆','😅','🤣','😂','🙂','🙃',
    '😉','😊','😇','🥰','😍','🤩','😘','😗','😚','😙','🥲','😋','😛','😜',
    '🤪','😝','🤑','🤗','🤭','🤫','🤔','🤐','🤨','😐','😑','😶','😏','😒',
    '🙄','😬','🤥','😌','😔','😪','🤤','😴','😷','🤒','🤕','🤢','🤮','🤧'];
  static const _people = ['👋','🤚','🖐','✋','🖖','👌','🤌','🤏','✌','🤞',
    '🤟','🤘','🤙','👈','👉','👆','👇','☝','👍','👎','✊','👊','🤛','🤜',
    '👏','🙌','👐','🤲','🤝','🙏','✍','💅','🤳','💪','🦾','🦵','🦶'];
  static const _animals = ['🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯',
    '🦁','🐮','🐷','🐸','🐵','🙈','🙉','🙊','🐔','🐧','🐦','🐤','🦆','🦅',
    '🦉','🦇','🐺','🐗','🐴','🦄','🐝','🐛','🦋','🐌','🐞','🐜'];
  static const _food = ['🍎','🍐','🍊','🍋','🍌','🍉','🍇','🍓','🫐','🍒',
    '🍑','🥭','🍍','🥥','🥝','🍅','🍆','🥑','🥦','🥬','🥒','🌶','🧄','🧅',
    '🥔','🍠','🥐','🥯','🍞','🥖','🧀','🥚','🍳','🧈','🥞','🧇','🥓','🥩'];
  static const _sports = ['⚽','🏀','🏈','⚾','🥎','🎾','🏐','🏉','🥏','🎱',
    '🏓','🏸','🏒','🏑','🥍','🏏','🥅','⛳','🏹','🎣','🤿','🥊','🥋','🎽',
    '🛹','🛼','🛷','⛸','🥌','🎿','⛷','🏂','🪂','🏋','🤼','🤸','⛹','🤺'];
  static const _objects = ['💡','🔦','🕯','🪔','🧯','💸','💵','💴','💶','💷',
    '🪙','💰','💳','💎','⚖','🪜','🧰','🪛','🔧','🔨','⚒','🛠','⛏','🪚',
    '🔩','🪤','🧲','🔫','💣','🪓','🔪','🗡','⚔','🛡','🪃','🏹','🪝'];
  static const _symbols = ['❤','🧡','💛','💚','💙','💜','🖤','🤍','🤎','💔',
    '❣','💕','💞','💓','💗','💖','💘','💝','💟','☮','✝','☪','🕉','☸',
    '✡','🔯','🕎','☯','☦','🛐','⛎','♈','♉','♊','♋','♌','♍','♎'];

  static const _all = [_recent,_smileys,_people,_animals,_food,_sports,_objects,_symbols];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = KbTheme.of(context);
    return Column(children: [
      Container(
        height: 40, color: t.toolbarBg,
        child: TabBar(
          controller: _tab,
          isScrollable: true,
          indicatorColor: const Color(0xFF007AFF),
          indicatorWeight: 2,
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          tabs: _tabs.map((e) => Tab(
            child: Text(e, style: const TextStyle(fontSize: 20)),
          )).toList(),
        ),
      ),
      Expanded(child: TabBarView(
        controller: _tab,
        children: List.generate(_tabs.length, (i) {
          final emojis = _all[i];
          if (emojis.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.history, size: 40, color: t.toolbarIcon),
              const SizedBox(height: 8),
              Text('No recent emojis',
                style: TextStyle(fontSize: 13, color: t.toolbarIcon)),
            ]));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8, childAspectRatio: 1),
            itemCount: emojis.length,
            itemBuilder: (_, idx) => GestureDetector(
              onTap: () => widget.controller.insertCharacter(emojis[idx]),
              child: Center(child: Text(emojis[idx],
                style: const TextStyle(fontSize: 26))),
            ),
          );
        }),
      )),
    ]);
  }
}
