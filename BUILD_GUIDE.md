# AB Keyboard - Build & Deployment Guide

## Quick Start

### Prerequisites
- Flutter 3.38.5+
- Android SDK 36+
- Java 17+
- Android device or emulator

### Step 1: Clean & Prepare
```bash
flutter clean
flutter pub get
```

### Step 2: Build APK

**Debug Build** (for testing):
```bash
flutter build apk --debug
```

**Release Build** (for production):
```bash
flutter build apk --release
```

### Step 3: Install on Device
```bash
flutter install
```

Or manually:
```bash
adb install build/app/outputs/apk/release/app-release.apk
```

---

## Setup on Device

### 1. Enable the Keyboard
1. Go to **Settings** → **General** → **Keyboard & input methods**
2. Tap **On-screen keyboard**
3. Select **AB Keyboard**
4. Tap **Enable**

### 2. Set as Default
1. Go to **Settings** → **General** → **Keyboard & input methods**
2. Tap **Default keyboard**
3. Select **AB Keyboard**

### 3. Launch Settings
- Open the AB Keyboard app from your launcher
- Configure keyboard appearance, behavior, and features

---

## Testing

### Basic Testing
1. Open any text field (Messages, Email, Notes)
2. Tap the text field to show keyboard
3. Verify keyboard appears at bottom (not fullscreen)
4. Test typing letters, numbers, symbols

### Feature Testing
- **Shift**: Single tap (capitalize once), double tap (caps lock)
- **Backspace**: Single tap (delete), long press (rapid delete)
- **Space**: Single space, double space (adds period + space)
- **Emoji**: Tap emoji button in toolbar
- **Clipboard**: Tap clipboard button in toolbar
- **Settings**: Tap settings button in toolbar

### Customization Testing
1. Open AB Keyboard app
2. Go to Settings tab
3. Test each customization option:
   - Color mode (Light/Dark/Auto)
   - Accent color
   - Key size and spacing
   - Keyboard height
   - Vibration and sound

---

## Troubleshooting

### Keyboard Not Appearing
1. Verify keyboard is enabled in Settings
2. Verify keyboard is set as default
3. Restart the device
4. Reinstall the app

### Keyboard Covering Screen
- This should not happen with current build
- If it does, check that IntrinsicHeight is in keyboard_widget.dart
- Verify FlutterBoardIME.kt uses WRAP_CONTENT height

### Settings Not Saving
1. Verify SharedPreferences is initialized
2. Check device storage permissions
3. Clear app cache and reinstall

### Crashes
1. Check logcat: `adb logcat | grep flutterboard`
2. Verify all method channels are properly named
3. Check that all imports are correct

---

## Build Output

After successful build, you'll find:

**Debug APK**:
```
build/app/outputs/apk/debug/app-debug.apk
```

**Release APK**:
```
build/app/outputs/apk/release/app-release.apk
```

---

## Performance Tips

1. **Reduce Keyboard Height**: Saves screen space
2. **Disable Shadows**: Slightly faster rendering
3. **Use Light Mode**: Slightly better battery life
4. **Disable Vibration**: Saves battery

---

## Distribution

### Google Play Store
1. Create signing key
2. Build release APK
3. Create Play Store listing
4. Upload APK
5. Set up screenshots and description

### Direct Distribution
1. Build release APK
2. Host on your server
3. Share download link
4. Users can install via "Install from file"

---

## Version Management

Current version: **1.0.0+1**

To update version:
1. Edit `pubspec.yaml`
2. Change `version: 1.0.0+1` to `version: 1.1.0+2`
3. Rebuild APK

---

## Support

For issues or questions:
1. Check PROJECT_SCAN_REPORT.md
2. Review code comments
3. Check Flutter documentation
4. Check Android IME documentation

---

**Last Updated**: April 22, 2026
