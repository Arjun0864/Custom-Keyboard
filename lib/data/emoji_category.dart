import 'package:flutter/material.dart';

class EmojiCategoryBar extends StatelessWidget {
  final Function(String) onCategorySelected;

  const EmojiCategoryBar({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCategoryIcon(Icons.emoji_emotions_outlined, 'Smileys'),
          _buildCategoryIcon(Icons.pets_outlined, 'Animals'),
          _buildCategoryIcon(Icons.fastfood_outlined, 'Food'),
          _buildCategoryIcon(Icons.directions_car_outlined, 'Travel'),
          _buildCategoryIcon(Icons.keyboard_return, 'Back'),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String category) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: () => onCategorySelected(category),
    );
  }
}
