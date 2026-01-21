# Voider Recorder

A cross-platform local voice recording app built with Flutter.

![Flutter](https://img.shields.io/badge/Flutter-3.38.7-blue)
![Dart](https://img.shields.io/badge/Dart-3.10.7-blue)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- ✅ **Voice Recording** - Record audio with customizable duration limits
- ✅ **Recording Management** - View, play, and manage all recordings
- ✅ **Playback with Time Display** - Real-time playback position tracking
- ✅ **File Sharing** - Share recordings directly from the app
- ✅ **Duration Limits** - Set custom recording time limits (1min, 5min, 10min, 30min, unlimited)
- ✅ **Pause/Resume** - Pause and resume recording sessions
- ✅ **Local Storage** - All recordings stored locally on device
- ✅ **Cross-Platform** - Works on Android, iOS, and Windows

## Tech Stack

- **Framework**: Flutter 3.38.7 (Dart 3.10.7)
- **State Management**: Provider
- **Audio Processing**: Flutter Sound 9.30.0
- **Platform Support**: Android 21+, iOS 12+, Windows 10+

## Dependencies

### Core Dependencies
- `flutter_sound` - Audio recording and playback
- `provider` - State management
- `path_provider` - File path access
- `permission_handler` - Runtime permissions
- `share_plus` - File sharing
- `intl` - Date/time formatting
- `logger` - Logging

See [pubspec.yaml](pubspec.yaml) for complete dependency list.

## Getting Started

### Prerequisites

- Flutter SDK 3.38.7 or higher
- Dart SDK 3.10.7 or higher
- Android Studio / VS Code (recommended)
- For Android: Android SDK 21+
- For iOS: Xcode 14+ and macOS 12+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/voider_recorder.git
   cd voider_recorder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**

   **Android:**
   ```bash
   flutter run
   # Or run on specific device
   flutter devices
   flutter run -d <device_id>
   ```

   **iOS:**
   ```bash
   flutter run
   ```

   **Windows:**
   ```bash
   flutter run -d windows
   ```

### Building

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (for Play Store):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS:**
```bash
flutter build ios --release
```

**Windows:**
```bash
flutter build windows --release
# Output: build/windows/runner/Release/
```

## Project Structure

```
lib/
├── config/           # Configuration constants
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── services/        # Business logic services
├── utils/          # Utility functions
└── widgets/        # Reusable UI components
```

### Key Components

- **AudioRecorderService** - Handles audio recording operations
- **RecordingProvider** - Manages recording state using Provider
- **FileManagerService** - File storage and retrieval
- **PermissionService** - Runtime permission handling
- **RecordingListScreen** - Recording list with playback
- **HomeScreen** - Main recording interface

## Development

### Code Style

The project follows the guidelines in [AGENTS.md](AGENTS.md):

- Import order: External → Internal
- Naming: PascalCase (classes), camelCase (functions/variables)
- Use `const` for widgets when possible
- Prefer `final` over `const` for non-static constructors
- Type-safe: No `as any` or `@ts-ignore`
- Comments: Chinese for business logic, English for technical comments

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Formatting

```bash
dart format . --set-exit-if-changed
```

## Configuration

### Recording Format

Default format: AAC/M4A for maximum compatibility.

### Permissions

**Android:**
- `RECORD_AUDIO` - Required for recording
- `READ_EXTERNAL_STORAGE` - Required for playing recordings
- `WRITE_EXTERNAL_STORAGE` - Required for saving recordings (Android < 10)

**iOS:**
- `NSMicrophoneUsageDescription` - Required for microphone access

See `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist` for configuration.

## Known Issues

- Windows build requires Visual Studio Build Tools with C++ development tools installed
- Gradle version 8.4 will soon be deprecated; consider upgrading to 8.7+

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Flutter](https://flutter.dev/) - Cross-platform UI framework
- [Flutter Sound](https://github.com/canardoux/tau) - Audio recording and playback
- [Provider](https://pub.dev/packages/provider) - State management

## Contact

For questions or feedback, please open an issue on GitHub.
