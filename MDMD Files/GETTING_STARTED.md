````markdown
# Getting Started with PDF Toolkit Flutter App

## Quick Start

### 1. Install Flutter

If you haven't installed Flutter yet:

**Windows:**
```powershell
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin
```

**macOS:**
```bash
# Using Homebrew
brew install flutter
```

**Linux:**
```bash
# Download and extract Flutter SDK
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x.x-stable.tar.xz
tar xf flutter_linux_3.x.x-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. Verify Installation

```bash
flutter doctor
```

This will check your environment and display a report of the status of your Flutter installation.

### 3. Install Dependencies

Navigate to the project directory and run:

```bash
cd h:\\StudioProjects\\pdf_toolkit
flutter pub get
```

### 4. Run the App

For development:
```bash
flutter run
```

For web:
```bash
flutter run -d chrome
```

For a specific device:
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Project Setup Checklist

- [ ] Flutter SDK installed (3.2.0+)
- [ ] Android Studio / Xcode installed (for mobile)
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Syncfusion license configured (free community license)
- [ ] Emulator or physical device connected
- [ ] App successfully builds and runs

## Configuration

### Syncfusion License

Syncfusion requires a license key for their packages. You can get a free community license:

1. Visit: https://www.syncfusion.com/sales/communitylicense
2. Register and get your license key
3. Add the license key to your app's `main.dart`:

```dart
import 'package:syncfusion_flutter_core/core.dart';

void main() {
  SyncfusionLicense.registerLicense('YOUR_LICENSE_KEY_HERE');
  runApp(const MyApp());
}
```

### Android Configuration

Edit `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

### iOS Configuration

Edit `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

## Development Tips

### Hot Reload

Press `r` in the terminal or use the IDE's hot reload button to see changes instantly without rebuilding the entire app.

### Hot Restart

Press `R` (capital R) for a full restart while keeping the app state.

### Debugging

1. **Print statements:**
```dart
print('Debug: $variableName');
```

2. **Debugger:**
```dart
debugger(); // Sets a breakpoint
```

3. **Flutter DevTools:**
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Code Formatting

```bash
# Format all Dart files
dart format .

# Check for issues
flutter analyze
```

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Common Commands

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Run tests
flutter test

# Check for outdated packages
flutter pub outdated

# Show device logs
flutter logs
```

## IDE Setup

### VS Code

Recommended extensions:
- Flutter
- Dart
- Flutter Widget Snippets
- Error Lens

### Android Studio

1. Install Flutter plugin
2. Install Dart plugin
3. Configure Flutter SDK path

## Troubleshooting

### Issue: "Waiting for another flutter command to release the startup lock"

```bash
killall -9 dart
flutter clean
flutter pub get
```

### Issue: Build fails with Gradle error

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: iOS build fails

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

### Issue: "Unable to load asset"

Make sure all assets are declared in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/fonts/
```

## Next Steps

1. Explore the codebase structure
2. Read the MIGRATION_GUIDE.md for detailed explanations
3. Try modifying a screen to understand the architecture
4. Run the app on different devices to test responsiveness
5. Check out Flutter's official documentation

## Resources

- Flutter Documentation: https://flutter.dev/docs
- Dart Documentation: https://dart.dev/guides
- Syncfusion Flutter PDF: https://help.syncfusion.com/flutter/pdf/overview
- Flutter Cookbook: https://flutter.dev/docs/cookbook
- Flutter Widget Catalog: https://flutter.dev/docs/development/ui/widgets

## Support

For issues or questions:
1. Check the README_FLUTTER.md file
2. Review the MIGRATION_GUIDE.md
3. Search Flutter's GitHub issues
4. Ask on Stack Overflow with the `flutter` tag

Happy coding! 🚀

````
