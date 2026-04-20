# Complete Project Structure - Custom Android Keyboard (Flutter)

## Flutter Dart Files (lib/)

### Core
| File | Purpose |
|------|---------|
| `lib/main.dart` | Entry point for the Flutter application |

### Keyboard Layer (lib/keyboard/)
| File | Purpose |
|------|---------|
| `lib/keyboard/keyboard_widget.dart` | Main keyboard UI widget rendering complete layout |
| `lib/keyboard/key_button.dart` | Individual key button with press animations and feedback |
| `lib/keyboard/keyboard_controller.dart` | Business logic for input, key mapping, text processing |

### Features (lib/features/)

#### Glide Typing (lib/features/glide_typing/)
| File | Purpose |
|------|---------|
| `lib/features/glide_typing/glide_typing_service.dart` | Swipe-to-type engine with path analysis |
| `lib/features/glide_typing/glide_typing_widget.dart` | UI for swipe visualization and interaction |

#### Clipboard (lib/features/clipboard/)
| File | Purpose |
|------|---------|
| `lib/features/clipboard/clipboard_manager.dart` | Copy/paste/history management |
| `lib/features/clipboard/clipboard_widget.dart` | UI panel for clipboard history |

#### Emoji (lib/features/emoji/)
| File | Purpose |
|------|---------|
| `lib/features/emoji/emoji_service.dart` | Emoji selection and categorization |
| `lib/features/emoji/emoji_widget.dart` | Emoji selector with categories and search |

#### Settings (lib/features/settings/)
| File | Purpose |
|------|---------|
| `lib/features/settings/settings_screen.dart` | Main settings UI screen |
| `lib/features/settings/settings_controller.dart` | Settings state and persistence logic |
| `lib/features/settings/theme_selector.dart` | Theme selection UI component |

### Themes (lib/themes/)
| File | Purpose |
|------|---------|
| `lib/themes/theme_provider.dart` | Light/dark modes and custom theme definitions |

### Models (lib/models/)
| File | Purpose |
|------|---------|
| `lib/models/key_model.dart` | Key properties (character, label, action type) |
| `lib/models/keyboard_layout_model.dart` | Keyboard layout structure (rows, arrangement) |
| `lib/models/settings_model.dart` | User settings and preferences data |
| `lib/models/emoji_model.dart` | Emoji data with category and metadata |
| `lib/models/clipboard_item_model.dart` | Clipboard item with timestamp and metadata |

### Services (lib/services/)
| File | Purpose |
|------|---------|
| `lib/services/input_method_service.dart` | Platform channel for IME Android integration |
| `lib/services/platform_channels.dart` | Flutter-to-native method channel bridge |
| `lib/services/settings_service.dart` | Persistent settings using SharedPreferences/Hive |
| `lib/services/haptic_service.dart` | Vibration feedback on key presses |
| `lib/services/audio_service.dart` | Sound effects for key presses |

### Providers (lib/providers/)
| File | Purpose |
|------|---------|
| `lib/providers/keyboard_provider.dart` | Global state management using Riverpod |

### Utils (lib/utils/)
| File | Purpose |
|------|---------|
| `lib/utils/constants.dart` | Key codes, layout data, config values |
| `lib/utils/extensions.dart` | Dart extensions for String, Color, etc. |
| `lib/utils/logger.dart` | Custom logging for debugging |
| `lib/utils/keyboard_layouts.dart` | QWERTY, AZERTY, Dvorak layout definitions |
| `lib/utils/glide_algorithm.dart` | Swipe path analysis algorithm |
| `lib/utils/emoji_data.dart` | Emoji database with categories and aliases |

### Root Config
| File | Purpose |
|------|---------|
| `pubspec.yaml` | Flutter dependencies and project metadata |

---

## Android Kotlin Files (android/app/src/main/kotlin/com/example/flutterboard/)

| File | Purpose |
|------|---------|
| `MainActivity.kt` | Flutter activity entry point |
| `FlutterBoardIME.kt` | InputMethodService implementation |
| `InputMethodManager.kt` | IME configuration and initialization |
| `KeyboardLayoutManager.kt` | Keyboard layout loading and key routing |
| `TextInputHandler.kt` | Text input connection and editing |
| `PlatformChannelHandler.kt` | Flutter-to-native method channel bridge |

---

## Android Resources (android/app/src/main/res/)

| File | Purpose |
|------|---------|
| `xml/method.xml` | IME service metadata configuration |

---

## Key Dependencies (pubspec.yaml)

**State Management:** provider, flutter_riverpod
**Storage:** shared_preferences, hive, sqflite, path_provider
**UI:** flutter_colorpicker, google_fonts, flutter_svg, lottie
**Input:** flutter_keyboard_visibility
**Keyboard:** vibration, audioplayers
**ML/NLP:** tflite_flutter (for word suggestions)
**Clipboard:** super_clipboard
**Utilities:** equatable, freezed, json_serializable, uuid, intl

---

## Architecture Overview

```
lib/
├── main.dart                          # App entry point
├── keyboard/
│   ├── keyboard_widget.dart           # Main UI
│   ├── key_button.dart                # Reusable key widget
│   └── keyboard_controller.dart       # Business logic
├── features/
│   ├── glide_typing/                  # Swipe input feature
│   ├── clipboard/                     # Clipboard management
│   ├── emoji/                         # Emoji selection
│   └── settings/                      # User preferences
├── models/                            # Data classes
├── services/                          # Business logic layers
├── providers/                         # State management
├── themes/                            # Styling
└── utils/                             # Helpers & constants

android/app/src/main/
├── kotlin/com/example/flutterboard/
│   ├── MainActivity.kt                # Flutter activity
│   ├── FlutterBoardIME.kt             # IME service
│   ├── InputMethodManager.kt          # IME setup
│   ├── KeyboardLayoutManager.kt       # Layout handling
│   ├── TextInputHandler.kt            # Input management
│   └── PlatformChannelHandler.kt      # Native bridge
└── res/xml/
    └── method.xml                      # IME metadata
```

---

## File Count Summary

- **Dart Files:** 29
- **Kotlin Files:** 6
- **Config/Metadata Files:** 1 (method.xml)
- **Total:** 36 files

---

## Next Steps

1. Implement each Dart file (start with models, then services, then UI)
2. Configure Android manifest with IME service
3. Set up platform channels for Flutter-Kotlin communication
4. Implement InputMethodService subclass in Kotlin
5. Add keyboard layout data and key mappings
6. Implement glide typing algorithm
7. Add emoji database
8. Set up state management with Riverpod
9. Build UI components
10. Test on physical device as IME service
