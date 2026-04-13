# FlutterBoard - Android System Keyboard

A production-ready, modern Android Input Method Editor (IME) keyboard built with Flutter, featuring:
- **Samsung Keyboard Style UI** with rounded keys and smooth animations
- **Material You Design** with light and dark themes
- **Smart Suggestions** engine
- **Emoji Panel** with quick emoji access
- **Clipboard Manager** with history
- **Multi-Language Support** (13+ languages)
- **Glide Typing** support
- **Haptic Feedback** (vibration on keys)
- **Customizable Themes** (Samsung, Gboard, Material, Glass, etc.)
- **Full IME Integration** with Android system

## Architecture

```
Flutter UI Components (keyboard_view.dart)
         ↓
MethodChannel (com.flutterboard/keyboard)
         ↓
Kotlin IME Service (FlutterBoardIME.kt)
         ↓
Android InputMethodService
         ↓
System Text Fields
```

## Quick Start

### Prerequisites

- Flutter 3.10.0 or higher
- Android SDK 21+ (API 21+)
- Android Studio / VS Code with Flutter extension

### Build & Install

1. **Clone/Setup the project:**
   ```bash
   cd Custom\ Keyboard
   flutter pub get
   ```

2. **Build the APK:**
   ```bash
   flutter build apk --release
   ```

3. **Install on device:**
   ```bash
   flutter install --release
   ```

4. **Run in debug mode (for development):**
   ```bash
   flutter run
   ```

## Enabling the Keyboard

After installation, the app appears in your launcher. To use it as your system keyboard:

### Step 1: Enable Keyboard
- Open FlutterBoard app
- Tap "Enable Keyboard" button
- Go to Settings > Language & input > Virtual keyboard > Manage keyboards
- Toggle ON for "FlutterBoard Keyboard"

### Step 2: Set as Default
- Go to Settings > Language & input > Default keyboard
- Select "FlutterBoard Keyboard"

### Step 3: Start Using
- Open any text field (messaging, email, notes, etc.)
- Keyboard should appear automatically

## Features

### Core IME Features
- ✅ Keyboard appears when tapping text fields
- ✅ Register in system keyboard list
- ✅ Can be enabled in Settings > Language & input
- ✅ Can be set as default keyboard
- ✅ Replace system keyboard when enabled

### UI Features
- ✅ **Samsung Keyboard Style** - Rounded keys, floating design
- ✅ **Modern Material Design** - Material You colors
- ✅ **Key Spacing & Animations** - Smooth key press effects
- ✅ **Suggestion Bar** - Smart word suggestions
- ✅ **Emoji Panel** - Quick emoji access
- ✅ **Clipboard Panel** - Clipboard history
- ✅ **Dark/Light Theme** - System theme integration
- ✅ **Multi-Language** - English, Hindi, Gujarati, Spanish, French, German, Italian, Portuguese, Russian, Chinese, Japanese, Korean

### Text Editing
- ✅ Text input & insertion
- ✅ Delete forward/backward
- ✅ Cursor movement
- ✅ Text selection (Select All)
- ✅ Composing text (for predictions)
- ✅ Editor actions (Done, Go, Search, Send, Next)
- ✅ Clipboard access (read/write)
- ✅ Surrounding text access

### Input Method Service (IMS)
- ✅ Full InputMethodService lifecycle
- ✅ EditorInfo handling
- ✅ Input connection management
- ✅ Selection updates
- ✅ Haptic feedback

## Keyboard Themes

FlutterBoard comes with multiple professional themes:

1. **Samsung Light/Dark** - Samsung One UI inspired
2. **Gboard Light/Dark** - Google Keyboard style
3. **Material Light/Dark** - Classic Material Design
4. **Material You Light/Dark** - Latest Material 3 colors
5. **Glass Light/Dark** - Glassmorphism with blur
6. **Cosmic Gradient** - Beautiful gradient theme
7. **AMOLED** - Pure black for OLED screens
8. **Minimal** - Minimalist borderless design

### Switch Themes
In the settings app, select your preferred theme. The keyboard will update immediately.

## Customization

### Keyboard Layout
Edit `lib/keyboard_state.dart` to modify keyboard layouts:
```dart
final currentLayout = const {
  'qwerty': ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
  'asdfgh': ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
};
```

### Keyboard Height
In `lib/keyboard_state.dart`:
```dart
this.keyboardHeight = 260.0, // Adjust this value (height in dp)
```

### Add New Language
1. Add to `android/app/src/main/res/xml/method.xml`:
```xml
<subtype
    android:label="Your Language"
    android:imeSubtypeLocale="xx_YY"
    android:imeSubtypeMode="keyboard"
    android:isAsciiCapable="false" />
```

2. Add string resources in `android/app/src/main/res/values/strings.xml`

### Custom Theme
In `lib/app_theme.dart`:
```dart
static KeyboardTheme get myCustomTheme => const KeyboardTheme(
  name: 'My Custom',
  type: KeyboardThemeType.material,
  backgroundColor: Color(0xFF...), // Your color
  keyColor: Color(0xFF...),
  // ... other properties
);
```

## File Structure

```
lib/
├── main.dart                 # App entry point & routing
├── keyboard_screen.dart      # Keyboard UI container
├── keyboard_view.dart        # Main keyboard component
├── keyboard_service.dart     # MethodChannel operations
├── keyboard_state.dart       # State management (Riverpod)
├── keyboard_layout.dart      # Keyboard row & key layout
├── keyboard_row.dart         # Single keyboard row
├── suggestion_bar.dart       # Word suggestions bar
├── emoji_panel.dart          # Emoji picker
├── clipboard_panel.dart      # Clipboard history
├── key_animation.dart        # Key press animations
├── app_theme.dart           # Theme definitions
├── app_constants.dart       # Constants & configs
└── ...

android/
├── app/src/main/
│   ├── AndroidManifest.xml  # IME service registration
│   ├── kotlin/
│   │   └── FlutterBoardIME.kt  # Kotlin IMS implementation
│   └── res/
│       ├── xml/
│       │   └── method.xml     # Keyboard subtypes & settings
│       ├── values/
│       │   ├── strings.xml    # String resources
│       │   ├── colors.xml     # Color palette
│       │   └── dimens.xml     # Dimensions
│       └── ...
```

## Key Android Files

### AndroidManifest.xml
- Declares `FlutterBoardIME` service with `BIND_INPUT_METHOD` permission
- Registers keyboard in system with `android.view.InputMethod` action
- References keyboard definition in `method.xml`

### FlutterBoardIME.kt
- Extends `InputMethodService`
- Manages Flutter engine lifecycle
- Handles all MethodChannel calls from Flutter
- Manages input connection & text operations
- Provides haptic feedback
- Handles clipboard operations

### method.xml
- Defines keyboard subtypes for each language
- Sets default keyboard subtype
- Links to settings activity

## Testing

### Test Keyboard Appearance
1. Install the app
2. Enable it in Settings > Language & input
3. Open any text field
4. Keyboard should appear at bottom

### Test Text Input
- Tap keys to input text
- Test backspace, space, return
- Test suggestions if enabled
- Test emoji panel

### Test Theme Switching
- Open Settings in app
- Change theme
- Open any text field
- Verify keyboard theme changed

### Test Multi-Language
- Go to Settings > Language & input > Languages
- Select different language subtype
- Keyboard should show that language's keys

## Build Variants

### Debug Build
```bash
flutter run -v
```
- Includes debug symbols
- Slower performance
- Good for development

### Release Build
```bash
flutter build apk --release
```
or
```bash
flutter build appbundle --release
```
- Optimized & smaller
- Better performance
- For production

## Troubleshooting

### Keyboard Doesn't Appear
1. Verify keyboard is enabled in Settings
2. Verify it's set as default
3. Restart the app
4. Check logcat for errors:
   ```bash
   adb logcat | grep FlutterBoard
   ```

### Keys Not Responding
1. Check if input connection is available
2. Verify MethodChannel calls are successful
3. Check for exceptions in Kotlin/Flutter code

### Theme Not Changing
1. Clear app cache: Settings > Apps > FlutterBoard > Storage > Clear Cache
2. Restart keyboard
3. Rebuild app

### Suggestion Not Working
1. Verify suggestion engine is enabled
2. Check if composing text is being set correctly
3. Look for exceptions in keyboard_service.dart

### Emoji Panel Crashes
1. Check clipboard_panel.dart implementation
2. Verify emoji list format
3. Check memory usage (may need pagination)

## Performance Tips

1. **Cache Flutter Engine** - Reduces startup time
2. **Use Riverpod** - Efficient state management
3. **Lazy Load Panels** - Load emoji/clipboard on demand
4. **Optimize Animations** - Keep 60fps for smooth UX
5. **Monitor Memory** - Keyboard services are always running

## Security Considerations

1. **Input Method Restrictions** - IME has access to all typed text
2. **Permissions** - Only request necessary permissions
3. **Data Privacy** - Don't log or transmit user input
4. **Clipboard Access** - Only read what user allows
5. **No Network** - Consider offline operation

## Dependencies

- **flutter_riverpod** - State management
- **shared_preferences** - Settings storage
- **hive_flutter** - Local database
- **permission_handler** - Android permissions
- **vibration** - Haptic feedback
- **super_clipboard** - Clipboard access
- **intl** - Internationalization
- **google_fonts** - Typography

## References

- [Android IME Documentation](https://developer.android.com/guide/topics/text/creating-input-method)
- [Flutter Platform Channels](https://flutter.dev/docs/development/platform-integration/platform-channels)
- [Material Design](https://material.io/design)
- [Flutter Riverpod](https://riverpod.dev/)

## Contributing

To improve FlutterBoard:
1. Report bugs & feature requests via GitHub Issues
2. Submit pull requests with improvements
3. Help translate to more languages
4. Share custom themes

## License

This project is open source and available under the MIT License.

## Credits

Built with ❤️ using Flutter and Kotlin.
Inspired by Samsung Keyboard, Gboard, and modern IME design practices.

---

**Version**: 1.0.0  
**Last Updated**: April 2026  
**Status**: Production Ready ✅
