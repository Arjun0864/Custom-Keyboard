# AB Keyboard - Complete Features Documentation

## Overview

AB Keyboard is a modern, feature-rich custom Android keyboard (IME) built with Flutter. It provides a Samsung One UI 6/7 style experience with extensive customization options.

---

## Core Keyboard Features

### 1. QWERTY Layout
- **Standard Layout**: 3 rows of letters (QWERTY, ASDFGH, ZXCVBNM)
- **Proper Spacing**: 4-6dp gaps between keys
- **Rounded Keys**: 12-16dp border radius
- **Soft Shadows**: 0.1-0.3 alpha, 2px blur
- **Ripple Effects**: Material ripple on all keys

### 2. Shift Key
- **Single Tap**: Capitalize next character only
- **Double Tap**: Toggle caps lock (all uppercase)
- **Visual Feedback**: 
  - Off: Gray arrow up icon
  - Once: Blue arrow up icon
  - Caps Lock: Blue capslock icon

### 3. Backspace Key
- **Single Tap**: Delete previous character
- **Long Press**: Rapid delete (5 characters)
- **Visual Feedback**: Backspace icon

### 4. Space Key
- **Single Space**: Normal space character
- **Double Space**: Automatically adds period + space
- **Auto-capitalize**: Next character capitalized after period

### 5. Enter Key
- **Accent Colored**: Uses theme accent color
- **Performs Action**: Sends IME action (done, go, search, etc.)
- **Visual Feedback**: Return icon

### 6. Number Layout (?123)
- **Toggle Button**: Switch between letters and numbers
- **Number Row 1**: 1 2 3 4 5 6 7 8 9 0
- **Number Row 2**: @ # $ % & - + ( )
- **Number Row 3**: * " ' : ; ! ?

### 7. Symbol Layout (=\<)
- **Toggle Button**: Switch between numbers and symbols
- **Symbol Row 1**: ~ ` | • √ π ÷ × ¶ ∆
- **Symbol Row 2**: £ ¢ € ¥ ^ ° = { }
- **Symbol Row 3**: \ / < > [ ] _

---

## Top Toolbar

Located above the keyboard, provides quick access to features:

### Emoji Button
- **Icon**: Smiley face
- **Function**: Toggle emoji keyboard panel
- **Active State**: Highlighted with accent color
- **Panel Height**: 280px

### Clipboard Button
- **Icon**: Paste icon
- **Function**: Toggle clipboard history panel
- **Active State**: Highlighted with accent color
- **Panel Height**: 280px
- **Features**: 
  - Recent clipboard items
  - Tap to paste
  - Long press for options

### Branding
- **Center Text**: "AB Keyboard"
- **Subtle Color**: White38 (light) / Black38 (dark)
- **Font Size**: 12px

### Settings Button
- **Icon**: Gear/settings icon
- **Function**: Toggle settings panel
- **Active State**: Highlighted with accent color
- **Panel Height**: 400px

---

## Expandable Panels

### Emoji Panel
- **Height**: 280px (expandable inside keyboard area)
- **Categories**: 
  - Recent
  - Smileys & Emotions
  - People & Body
  - Animals & Nature
  - Food & Drink
  - Travel & Places
  - Objects
  - Symbols
- **Features**:
  - Smooth height animation
  - Tap to insert emoji
  - Recent emoji tracking
  - Category tabs

### Clipboard Panel
- **Height**: 280px (expandable inside keyboard area)
- **Features**:
  - Recent clipboard items
  - Tap to paste
  - Long press to delete
  - Pin important items
  - Time since copied
  - Horizontal scrollable list

### Settings Panel
- **Height**: 400px (expandable inside keyboard area)
- **4 Tabs**:
  1. **Style Tab**: Colors, themes, appearance
  2. **Keys Tab**: Key size, shape, spacing, shadows
  3. **Feedback Tab**: Vibration, sound, animations
  4. **Layout Tab**: Height, one-handed mode, floating

---

## Settings & Customization

### Style Tab

#### Color Mode
- **Light**: #F4F5F7 background, #FFFFFF keys, #111111 text
- **Dark**: #1C1C1E background, #2C2C2E keys, #FFFFFF text
- **Auto**: Follows system preference

#### Accent Color
- **12 Samsung Presets**: Blue, Purple, Pink, Red, Orange, Yellow, Green, Teal, Cyan, Indigo, Deep Purple, Gray
- **Custom Color**: Hex color picker
- **Live Preview**: See changes in real-time

#### Key Opacity
- **Range**: 0.0 - 1.0
- **Default**: 1.0 (fully opaque)
- **Use Case**: Transparency effects

### Keys Tab

#### Key Shape
- **Rectangle**: Sharp corners
- **Rounded**: 12-16dp radius (default)
- **Bubble**: Highly rounded
- **Minimal**: Flat design

#### Border Radius
- **Range**: 0 - 20dp
- **Default**: 8dp
- **Live Preview**: See changes instantly

#### Key Gap Spacing
- **Range**: 2 - 8dp
- **Default**: 4dp
- **Effect**: Space between keys

#### Key Shadow
- **Toggle**: Enable/disable shadows
- **Intensity**: 0.0 - 1.0
- **Effect**: Depth perception

#### Font Size
- **Range**: 12 - 18px
- **Default**: 16px
- **Effect**: Text size on keys

### Feedback Tab

#### Vibration
- **Intensity**: 0 (off) - 3 (strong)
- **Default**: 2 (medium)
- **Triggers**: On every key press

#### Sound Theme
- **Off**: No sound
- **Click**: Subtle click sound
- **Typewriter**: Mechanical typewriter sound
- **Soft**: Soft beep
- **Pop**: Pop sound

#### Key Animation
- **None**: No animation
- **Scale**: Keys scale on press
- **Ripple**: Material ripple effect
- **Bounce**: Bouncy animation

### Layout Tab

#### Keyboard Height
- **Presets**: 
  - Compact: 200px
  - Normal: 250px (default)
  - Large: 300px
  - XL: 350px
- **Custom**: Slider for any height
- **Effect**: Keyboard size on screen

#### One-Handed Mode
- **Off**: Normal layout
- **Left**: Keyboard shifted to left side
- **Right**: Keyboard shifted to right side
- **Shift Percent**: 10 - 50% (default 30%)

#### Floating Mode
- **Toggle**: Enable/disable floating keyboard
- **Size**: 50 - 100% of screen width (default 80%)
- **Effect**: Keyboard floats above content

#### Row Stagger
- **Toggle**: Offset rows for ergonomics
- **Effect**: Slightly offset each row

---

## Auto-Capitalize Feature

Automatically capitalizes letters in these situations:

1. **Start of Text**: First character is capitalized
2. **After Period**: Character after `. ` is capitalized
3. **After Exclamation**: Character after `! ` is capitalized
4. **After Question**: Character after `? ` is capitalized

### Example
```
hello world. this is a test! how are you?
Hello world. This is a test! How are you?
```

---

## Double-Space Period Feature

Typing space twice automatically adds a period:

### Example
```
User types: "hello" + space + space
Result: "hello. "
```

---

## Language Support

Configured for 14 languages:

1. **English (US)** - Default
2. **English (UK)**
3. **Hindi**
4. **Gujarati**
5. **Spanish**
6. **French**
7. **German**
8. **Italian**
9. **Portuguese**
10. **Russian**
11. **Chinese (Simplified)**
12. **Chinese (Traditional)**
13. **Japanese**
14. **Korean**

---

## Theme System

### Samsung Color Presets
```
Blue       #2196F3
Purple     #9C27B0
Pink       #E91E63
Red        #F44336
Orange     #FF9800
Yellow     #FFC107
Green      #4CAF50
Teal       #009688
Cyan       #00BCD4
Indigo     #3F51B5
Deep Purple #673AB7
Gray       #9E9E9E
```

### Custom Themes
- **Save Current Theme**: Save current settings as preset
- **Load Theme**: Apply saved theme
- **Delete Theme**: Remove saved theme
- **Persistence**: Saved to SharedPreferences

---

## Haptic Feedback

### Vibration Levels
- **Level 0**: Off (no vibration)
- **Level 1**: Light (10ms)
- **Level 2**: Medium (30ms) - Default
- **Level 3**: Strong (50ms)

### Triggers
- Every key press
- Configurable intensity
- Can be disabled

---

## Sound Effects

### Sound Themes
1. **Off**: No sound
2. **Click**: Subtle click (default)
3. **Typewriter**: Mechanical sound
4. **Soft**: Soft beep
5. **Pop**: Pop sound

### Triggers
- Every key press
- Configurable theme
- Can be disabled

---

## Method Channel Communication

### Available Methods

#### Text Input
- `commitText(text)`: Insert text
- `deleteBackward()`: Delete previous character
- `deleteForward()`: Delete next character
- `commitAction(action)`: Perform editor action

#### Text Operations
- `getSelectedText()`: Get selected text
- `moveCursor(offset)`: Move cursor
- `selectAll()`: Select all text
- `setComposingText(text)`: Set composing text
- `finishComposing()`: Finish composing

#### Keyboard Control
- `hideKeyboard()`: Hide keyboard
- `setKeyboardHeight(height)`: Set height in pixels
- `switchToPreviousInputMethod()`: Switch to previous IME

#### Feedback
- `vibrate(duration, strength)`: Trigger vibration
- `getEditorInfo()`: Get current editor info

#### Clipboard
- `getClipboardText()`: Get clipboard content
- `setClipboardText(text)`: Set clipboard content

---

## Performance Optimizations

1. **IntrinsicHeight**: Proper keyboard sizing (wrap_content)
2. **Lazy Loading**: Panels load on demand
3. **Efficient Rendering**: Minimal rebuilds
4. **Memory Management**: Proper disposal of resources
5. **Method Channel**: Direct native communication

---

## Accessibility Features

1. **Proper Contrast**: Text readable in light/dark modes
2. **Touch Targets**: Keys are 46px minimum height
3. **Ripple Feedback**: Visual feedback on key press
4. **Haptic Feedback**: Vibration on key press
5. **Sound Feedback**: Optional sound effects

---

## Security & Privacy

1. **Local Storage Only**: All data stored locally
2. **No Telemetry**: No tracking or analytics
3. **No Network Calls**: Keyboard input never sent online
4. **Clipboard Access**: Only when explicitly used
5. **Permissions**: Only necessary permissions requested

---

## Known Limitations

1. **Glide Typing**: Not yet implemented (planned)
2. **Word Suggestions**: Not yet implemented (planned)
3. **Auto-Correct**: Not yet implemented (planned)
4. **Gesture Support**: Limited (planned for future)
5. **Cloud Sync**: Not available (planned)

---

## Future Features

1. **Glide Typing**: Swipe to type
2. **Word Suggestions**: Predictive text
3. **Auto-Correct**: Automatic spelling correction
4. **Gesture Shortcuts**: Custom gestures
5. **Cloud Sync**: Sync settings across devices
6. **Keyboard Shortcuts**: Custom key combinations
7. **Themes Store**: Download community themes
8. **Multi-Language**: More language support

---

## Troubleshooting

### Keyboard Not Responding
1. Verify keyboard is enabled
2. Verify keyboard is set as default
3. Restart the app
4. Restart the device

### Settings Not Saving
1. Check storage permissions
2. Clear app cache
3. Reinstall the app

### Crashes
1. Check logcat for errors
2. Verify all method channels are correct
3. Check for null pointer exceptions

### Performance Issues
1. Reduce keyboard height
2. Disable shadows
3. Disable vibration
4. Disable sound effects

---

**Last Updated**: April 22, 2026  
**Version**: 1.0.0+1
