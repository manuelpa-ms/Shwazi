# Flutter Installation Guide

## Prerequisites
Flutter is required to run this project. Follow these steps to install Flutter:

### Windows Installation

1. **Download Flutter SDK**
   - Go to https://flutter.dev/docs/get-started/install/windows
   - Download the latest stable release
   - Extract to `C:\flutter` (or your preferred location)

2. **Update PATH**
   - Add `C:\flutter\bin` to your system PATH
   - Restart VS Code after updating PATH

3. **Run Flutter Doctor**
   ```bash
   flutter doctor
   ```
   This will check your installation and show what dependencies are needed.

4. **Install Dependencies**
   - Android Studio (for Android development)
   - Xcode (for iOS development - macOS only)
   - Chrome (for web development)

### After Flutter Installation

1. **Get Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

3. **Or use VS Code Tasks**
   - Press `Ctrl+Shift+P`
   - Type "Tasks: Run Task"
   - Select "Flutter: Run App"

### Alternative: Use GitHub Codespaces or GitPod
If you want to try the app without installing Flutter locally:
1. Fork this repository on GitHub
2. Open it in GitHub Codespaces or GitPod
3. Flutter will be pre-installed in the cloud environment

## Troubleshooting

- **Flutter not recognized**: Make sure Flutter is in your PATH
- **Android licenses**: Run `flutter doctor --android-licenses` and accept all
- **iOS setup**: Run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`

For detailed setup instructions, visit: https://flutter.dev/docs/get-started/install
