import 'package:hive_flutter/hive_flutter.dart';

class SettingsRepository {
  static late Box _settingsBox;
  static late Box _clipboardBox;
  static late Box _dictionaryBox;

  static Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
    _clipboardBox = await Hive.openBox('clipboard');
    _dictionaryBox = await Hive.openBox('dictionary');
  }

  static Box get settings => _settingsBox;
  static Box get clipboard => _clipboardBox;
  static Box get dictionary => _dictionaryBox;
}
