import 'package:flutter/material.dart';
import 'theme_selector.dart';
import '../ui/keyboard_height_slider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Keyboard Settings"),
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text("Theme & Appearance"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeSelector())),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Layout", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          const KeyboardHeightSlider(),
          SwitchListTile(
            title: const Text("Number Row"),
            subtitle: const Text("Show numbers at the top of the QWERTY layout"),
            value: true,
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }
}
