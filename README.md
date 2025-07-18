# Finger Picker App

A multi-platform Flutter app that helps choose a finger between those tracked on the screen. Perfect for making quick group decisions!

## Features

- **Multi-touch tracking**: Each finger that touches the screen gets a unique colored circle
- **Animated circles**: Smooth entry animations and real-time position tracking
- **5-second countdown**: Timer starts when 2 or more fingers are detected
- **Random selection**: One finger is randomly chosen when the timer expires
- **Winner highlight**: The selected finger's color expands to fill the screen
- **Quick reset**: Tap anywhere after selection to start a new round

## How to Use

1. Launch the app
2. Have multiple people touch the screen simultaneously
3. Watch the countdown timer (appears when 2+ fingers are detected)
4. See the winner announcement with the selected finger highlighted
5. Tap anywhere to start a new round

## Technical Details

- **Framework**: Flutter 3.10+
- **State Management**: Provider pattern
- **Platform Support**: Android (API 21+) and iOS
- **Performance**: 60+ FPS animations with efficient custom painting

## Getting Started

### Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode for mobile development

### Installation

1. Clone this repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Building for Release

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/
│   └── game_screen.dart     # Main game interface
├── services/
│   └── game_logic.dart      # Core game logic and state
├── models/
│   └── finger_data.dart     # Finger tracking data model
├── widgets/
│   ├── finger_circle.dart   # Custom circle painter
│   └── countdown_timer.dart # Timer display widget
└── utils/
    └── color_generator.dart # Color management utility
```

## Performance Optimizations

- Efficient custom painting for smooth circle rendering
- Optimized state management to minimize rebuilds
- Smooth 60+ FPS animations
- Memory-efficient finger tracking

## Contributing

Feel free to submit issues and pull requests to improve the app!

## License

This project is open source and available under the [MIT License](LICENSE).
