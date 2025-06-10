# Zifromania

Zifromania is a dynamic math puzzle game designed to boost your brainpower. It's a mobile game built with Flutter, offering a fresh challenge every time you play. Engage your mind, improve your problem-solving skills, and experience a fun way to enhance cognitive agility.

## Features

- Engaging math puzzles
- Multiple categories
- Diverse mathematical operations
- User authentication (Firebase Auth)
- Leaderboards (Cloud Firestore)
- Achievements
- In-app purchases / subscriptions
- Customizable settings (e.g., sound, notifications)
- Daily rewards
- Localization (multiple language support)

## Technologies Used

- Flutter (for cross-platform mobile development)
- Dart
- Firebase (Authentication, Cloud Firestore, Remote Config)
- Bloc (for state management)
- Google Mobile Ads

## Project Structure

- `lib/`: Contains the Dart code for the application.
    - `main.dart`: Entry point of the application.
    - `app.dart`: Root widget of the application.
    - `core/`: Core utilities, constants, and theme.
    - `data/`: Data layer (models, repositories).
    - `domain/`: Domain layer (entities, usecases, repository contracts).
    - `presentation/`: Presentation layer (screens, widgets, state management).
    - `services/`: Various application services (auth, ads, audio, etc.).
- `assets/`: Contains static assets like images, fonts, sounds, and translations.
- `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`: Platform-specific code.
- `test/`: Contains application tests.

## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- An IDE like Android Studio or VS Code with the Flutter plugin.

### Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/zifromania.git
   cd zifromania
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Firebase Setup:**
   - Create a Firebase project at [https://console.firebase.google.com/](https://console.firebase.google.com/).
   - Add an Android app and an iOS app to your Firebase project.
   - Follow the Firebase console instructions to download the `google-services.json` file for Android and the `GoogleService-Info.plist` file for iOS.
   - Place `google-services.json` into the `android/app/` directory.
   - Place `GoogleService-Info.plist` into the `ios/Runner/` directory (use Xcode to add this file).
   - Ensure you have configured Firebase Authentication, Cloud Firestore, and Remote Config in your Firebase project.

4. **Run the app:**
   ```bash
   flutter run
   ```

## Contributing

Contributions are welcome! Please follow standard GitHub flow: Fork, Branch, Commit, Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details. (Note: LICENSE.md file not yet created)