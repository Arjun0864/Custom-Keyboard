# FlutterBoard - Quick Start Guide

Get your custom Android keyboard up and running in 5 minutes!

## ⚡ Quick Setup (5 Minutes)

### Step 1: Build and Install (2 min)

```bash
# Navigate to project directory
cd Custom\ Keyboard

# Get dependencies
flutter pub get

# Build and install on connected device
flutter run --release
```

**Or via Android Studio:**
- Open the project in Android Studio
- Click "Run" → Select device
- Wait for build to complete

**Or manually:**
```bash
flutter build apk --release
adb install build/app/outputs/apk/release/app-release.apk
```

### Step 2: Enable Keyboard (2 min)

1. **Open the FlutterBoard app** from your launcher
2. **Tap "Enable FlutterBoard"** button
3. **Follow the on-screen steps:**
   - Tap "Go to Settings"
   - Go to `Settings > Language & input > Virtual keyboard > Manage keyboards`
   - Toggle ON for "FlutterBoard"

### Step 3: Set as Default (1 min)

1. Go to `Settings > Language & input`
2. Tap "Default keyboard"
3. Select "FlutterBoard Keyboard"

### Step 4: Test It! (Start typing)

1. Open any text app (Gmail, Messages, Notes, etc.)
2. Tap a text field
3. Your new keyboard should appear! 🎉

---

## 🎨 First Time Using It

### What You'll See
- **Numbers row** at the top (1-9, 0)
- **QWERTY layout** with rounded keys
- **Space bar** in the middle
- **Emoji button** (😊) - tap for emojis
- **Settings icon** (⚙️) - tap for more options

### Try These
- **Type text** - Just tap keys normally
- **Backspace** - Tap the ⌫ (back arrow) key
- **Emoji** - Tap 😊 button to see emoji panel
- **Space** - Tap the large space bar
- **Number symbols** - They're in the top row

---

## 🎨 Customize Your Keyboard

### Change Theme

1. **Open FlutterBoard app**
2. **Tap "Settings" tab** (bottom navigation)
3. **Select "Theme Mode"** (Light/Dark/System)
4. **Open any text field** - Theme applies instantly!

### Available Themes
- **Samsung Light/Dark** ← Modern Samsung One UI style
- **Gboard Light/Dark** ← Google Keyboard style
- **Material Light/Dark** ← Classic Material Design
- **Material You** ← Latest Google design
- **Glass Light/Dark** ← Frosted glass with blur
- **Cosmic Gradient** ← Purple gradient theme
- **AMOLED** ← Pure black for OLED screens
- **Minimal** ← Clean, no borders

### Change Language

1. Go to `Settings > Language & input`
2. Scroll down to "Keyboard languages"
3. Select from available languages:
   - English (US/UK is default)
   - Hindi
   - Gujarati
   - Spanish
   - French
   - German
   - Italian
   - Portuguese
   - Russian
   - Chinese (Simplified/Traditional)
   - Japanese
   - Korean

---

## 📱 Common Tasks

### Hide Keyboard
- Tap back button (usually)
- Swipe down from keyboard
- Or the keyboard hides automatically when done

### Use Keyboard as System Default
✅ Done in Step 2-3 above

### Switch Back to System Keyboard
1. Go to `Settings > Language & input`
2. Tap "Default keyboard"
3. Select another keyboard
4. System keyboard returns when you type

### Clear App Data
1. Go to `Settings > Apps > FlutterBoard`
2. Tap "Storage"
3. Tap "Clear Cache" (keeps settings)
4. Or "Clear Data" (resets everything)

### Uninstall
1. Long press FlutterBoard app icon
2. Select "Uninstall"
3. Confirm

---

## 🔧 Debug & Troubleshooting

### Keyboard Not Appearing?

**Check 1: Is it enabled?**
```
Settings > Language & input > Virtual keyboard > Manage keyboards
→ Look for "FlutterBoard" and ensure it's toggled ON
```

**Check 2: Is it the default?**
```
Settings > Language & input > Default keyboard
→ Should show "FlutterBoard Keyboard"
```

**Check 3: Restart**
- Close the app completely (not just minimize)
- Open a text field again
- Keyboard should appear

**Debug: Check System Logs**
```bash
adb logcat | grep -i flutterboard
```

### Theme Not Changing?

1. **Clear app cache:**
   ```
   Settings > Apps > FlutterBoard > Storage > Clear Cache
   ```

2. **Reopen keyboard** - Type in a new text field

3. **Rebuild app:**
   ```bash
   flutter clean
   flutter run --release
   ```

### Keys Not Working?

1. Try in a different app (Gmail, Messages, Notes)
2. Check if input connection is active
3. Look in System Logs:
   ```bash
   adb logcat | grep MethodChannel
   ```

### App Crashes?

1. Check Android version (requires API 21+)
2. View crash log:
   ```bash
   adb logcat | grep Exception
   ```
3. Rebuild the app:
   ```bash
   flutter clean && flutter build apk --release
   ```

---

## ✨ Pro Tips

### Faster Switching Between Keyboards
**Tip:** Here's the Android shortcut:
- Long press anywhere in a text field
- Select "Input method" 
- Choose your keyboard instantly!

### Keyboard Shortcuts
- **Space bar** - Type space or move cursor in some apps
- **Return key** - New line in Messages, Send in Gmail
- **Backspace** - Delete previous character

### Better Feedback
- **Enable vibration** in keyboard settings (haptic feedback)
- **Sound effects** coming in future updates

---

## 📚 More Features (Coming Soon)

- 🎙️ Voice input
- 🎯 Gesture typing / Glide
- 🤖 AI-powered predictions
- 💾 Cloud sync (optional)
- 🎨 Custom themes you create
- ⚡ Faster predictions

---

## 🆘 Need Help?

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| **Keyboard not appearing** | Ensure enabled in Settings > Language & input |
| **Text not typing** | Check keyboard enabled |
| **Theme not changing** | Clear cache, restart, rebuild app |
| **Lag or stuttering** | Close other apps, reduce keyboard height |
| **Suggestions not showing** | Enable in keyboard settings (toggle suggestions on) |
| **Emoji panel crashes** | Restart app, clear cache |

---

## 🚀 Build Your Own Version

### Customize Colors
Edit `lib/app_theme.dart`:
```dart
backgroundColor: Color(0xFFYourColor), // Change this
keyColor: Color(0xFFYourColor),
```

### Change Keyboard Layout
Edit `lib/keyboard_state.dart`:
```dart
'qwerty': ['Q', 'W', 'E', ...], // Custom layout
```

### Add Your App Logo
Replace icon at `android/app/src/main/res/mipmap-*/ic_launcher.png`

---

## 📊 System Requirements

- **Android**: 5.0 (API 21) or higher
- **RAM**: 100MB+ (for keyboard process)
- **Storage**: 50MB+ for app
- **Flutter**: 3.10.0 or higher

---

## ✅ Verification Checklist

After setup, verify:
- ✅ App appears in launcher
- ✅ Keyboard in Settings > Language & input list
- ✅ Can set as default keyboard
- ✅ Keyboard appears in text fields
- ✅ Text input works
- ✅ Backspace works
- ✅ Emoji panel opens
- ✅ Theme changes apply
- ✅ No crashes in logcat

---

## 🎉 You're Done!

Your custom keyboard is now ready to use on your Android device!

**Next steps:**
1. Try typing in different apps
2. Switch themes in settings
3. Explore emoji and clipboard panels
4. Customize to your preference

**Feedback:**
- Found a bug? Check logcat for errors
- Want a feature? Check IMPLEMENTATION_GUIDE.md

---

**Happy typing!** 📝✨

---

For more details, see:
- `README.md` - Full documentation
- `IMPLEMENTATION_GUIDE.md` - Technical details


---

## 🎯 KEY FEATURES IMPLEMENTED

✅ **Text Input**
- Full QWERTY keyboard support
- Multiple language support (English, Hindi, Gujarati)
- Transliteration engine for Indian languages

✅ **Advanced Features**
- Word suggestions with auto-completion
- Emoji picker with category tabs
- Clipboard history with pin functionality
- Material Design themes (7 built-in themes)
- Dark mode support

✅ **Customization**
- 7 built-in themes to choose from
- Keyboard height adjustment
- Custom key colors and styling
- Font customization

✅ **Performance**
- Optimized rendering
- Minimal lag
- Efficient state management with Riverpod
- Proper lifecycle management

---

## 📝 FILE STRUCTURE

```
Custom Keyboard/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── keyboard_screen.dart               # Main keyboard UI
│   ├── keyboard_view.dart                 # Alternative keyboard view
│   ├── keyboard_layout.dart              # Keyboard layout builder
│   ├── keyboard_key.dart                 # Individual key widget
│   ├── keyboard_row.dart                 # Keyboard row container
│   ├── keyboard_state.dart               # State management (Riverpod)
│   ├── keyboard_channel_service.dart     # Method channel communication
│   ├── keyboard_service.dart             # Keyboard service (legacy)
│   ├── app_theme.dart                    # Theme definitions
│   ├── app_constants.dart                # App constants
│   ├── settings_repository.dart          # Hive persistence
│   ├── suggestion_engine.dart            # Word suggestions
│   ├── suggestion_bar & suggestion_chip.dart  # Suggestion UI
│   ├── glide_typing_service.dart         # Glide typing support
│   ├── transliteration_engine.dart       # Language transliteration
│   ├── clipboard_manager.dart            # Clipboard history
│   ├── clipboard_panel.dart              # Clipboard UI
│   ├── emoji_panel.dart                  # Emoji picker
│   ├── emoji_category.dart               # Emoji categories
│   ├── theme_selector.dart               # Theme selection UI
│   ├── keyboard_customizer.dart          # Keyboard customization
│   ├── keyboard_height_slider.dart       # Height adjustment
│   ├── floating_keyboard.dart            # Floating keyboard mode
│   ├── key_animation.dart                # Key press animations
│   ├── settings_screen.dart              # Settings UI
│   ├── keyboard_settings.dart            # Settings model
│   └── pubspec.yaml                      # Dependencies
│
├── android/
│   ├── AndroidManifest.xml              # App manifest
│   ├── build.gradle                     # Gradle configuration
│   ├── MainActivity.kt                  # Main activity
│   ├── FlutterBoardIME.kt              # IME service
│   └── res/
│       ├── values/strings.xml
│       └── xml/method.xml               # IME configuration
│
└── Other files
    ├── pubspec.yaml
    ├── pubspec.lock
    └── .flutter-plugins-dependencies
```

---

## 🔧 TROUBLESHOOTING

### Keyboard not appearing in system keyboard list?
- Ensure `FlutterBoardIME` service is exported in `AndroidManifest.xml`
- Check that permissions are properly declared
- Verify `method.xml` is correctly configured

### Suggestion not working?
- The suggestion engine requires user input history
- First few keystrokes may not have suggestions
- Check that N-gram model is properly initialized

### Theme not saving?
- Ensure `SharedPreferences` and `Hive` are properly initialized
- Check that `settings_repository.dart` is initialized in `main()``

### Performance issues?
- Check if suggestions are generating too many options
- Reduce suggestion limit in configuration
- Disable glide typing if not needed

---

## 🆘 DEBUG TIPS

### Enable Flutter Logging
```bash
flutter run -v
```

### Check Kotlin/Android Logs
```bash
adb logcat | grep FlutterBoard
```

### Build with Debug Info
```bash
flutter build apk --debug --verbose
```

---

## 📦 DEPENDENCIES USED

**Core**
- `flutter_riverpod`: State management
- `provider`: Provider pattern (backward compat)
- `hive_flutter`: Local data persistence
- `shared_preferences`: Simple key-value storage

**UI & Animations**
- `flutter_animate`: Animation utilities
- `lottie`: Lottie animations
- `google_fonts`: Additional fonts

**Utilities**
- `intl`: Internationalization
- `uuid`: Unique ID generation
- `vibration`: Haptic feedback
- `collection`: Dart collection utilities

**Optional**
- `permission_handler`: Runtime permissions
- `http`: Network requests
- `cached_network_image`: Image caching

---

## ✅ PRE-LAUNCH CHECKLIST

- [ ] Flutter version >=3.10.0
- [ ] Android SDK 24+ installed
- [ ] Gradle 8.0+ configured
- [ ] All dependencies resolved (`flutter pub get`)
- [ ] No compilation errors (`flutter analyze`)
- [ ] AndroidManifest.xml properly configured
- [ ] Keyboard appears in Settings → Languages & Input
- [ ] Basic text input works
- [ ] Backspace/Delete functions properly
- [ ] Theme switching works
- [ ] Settings persist after restart
- [ ] Emoji picker functions
- [ ] Clipboard history available

---

## 🎓 ARCHITECTURE OVERVIEW

### State Management (Riverpod)
```
keyboardStateProvider → KeyboardState
keyboardThemeProvider → KeyboardTheme
clipboardManagerProvider → List<ClipboardItem>
suggestionEngineProvider → SuggestionEngine
glideTypingServiceProvider → GlideTypingService
```

### Method Channels
```
com.flutterboard/keyboard → Text input, haptics
com.flutterboard/keyboard_events → Event streaming
com.flutterboard/input → Clipboard operations
com.flutterboard/settings → Keyboard settings
```

### Data Flow
```
User Input
    ↓
KeyboardKey (onTap)
    ↓
KeyboardStateNotifier
    ↓
KeyboardChannelService
    ↓
FlutterBoardIME (Kotlin)
    ↓
InputConnection
    ↓
Text Editor
```

---

## 📞 SUPPORT

For issues or questions, check:
1. `ERROR_ANALYSIS.md` - Detailed error documentation
2. `FIX_SUMMARY.md` - Completed fixes list
3. Flutter documentation: https://flutter.dev
4. AndroidInputMethod documentation

---

**Last Updated**: April 12, 2026
**Status**: ✅ PRODUCTION READY
**Version**: 1.0.0+1
