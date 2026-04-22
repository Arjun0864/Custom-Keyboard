import 'package:flutter/material.dart';
import 'keyboard_theme.dart';

/// Samsung One UI suggestion bar — 3 slots, center bold, dividers.
class SuggestionBar extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  const SuggestionBar({
    super.key,
    required this.suggestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = KbColors.of(context);
    // Pad/trim to exactly 3
    final words = List<String>.generate(
        3, (i) => i < suggestions.length ? suggestions[i] : '');

    return Container(
      height: 40,
      color: colors.suggestionBg,
      child: Row(
        children: [
          _slot(context, words[0], center: false, colors: colors),
          _divider(colors),
          _slot(context, words[1], center: true,  colors: colors),
          _divider(colors),
          _slot(context, words[2], center: false, colors: colors),
        ],
      ),
    );
  }

  Widget _slot(BuildContext ctx, String word,
      {required bool center, required KbColors colors}) {
    return Expanded(
      child: InkWell(
        onTap: word.isEmpty ? null : () => onTap(word),
        child: Center(
          child: Text(
            word,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: center ? FontWeight.bold : FontWeight.normal,
              color: center ? colors.suggestionText : colors.suggestionSide,
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider(KbColors colors) => SizedBox(
        height: 20,
        child: VerticalDivider(width: 1, color: colors.divider),
      );
}
