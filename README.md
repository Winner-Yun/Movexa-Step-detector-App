# Movexa - Step Detector App 🏃‍♂️

Movexa is a Flutter-based fitness application designed to track your daily steps, estimate calories burned, and monitor your physical activity. Built with a clean architecture and powered by Firebase, this app offers a seamless and engaging experience for users looking to stay active.

## Features ✨

- **Real-time Step Tracking**: Accurate background and foreground step counting using the `pedometer` package.
- **User Authentication**: Secure Google Sign-In and Email authentication powered by Firebase Auth.
- **Cloud Sync**: All your progress and profile data is securely stored and synced via Cloud Firestore.
- **Permissions Management**: Graceful handling of physical activity permissions across devices.
- **Gamification**: Hit your daily goals and earn achievements.
- **Beautiful UI**: Built with a sleek, modern aesthetic using Google Fonts (Kantumruy Pro & Nokora) and dynamic theming.

## Tech Stack 🛠

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Backend**: Firebase (Auth, Firestore)
- **Key Packages**: 
  - `pedometer` for step detection
  - `permission_handler` for sensor permissions
  - `google_sign_in` for authentication
  - `google_fonts` for typography

## Setup Instructions 🚀

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd step_detector
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a project on the [Firebase Console](https://console.firebase.google.com/).
   - Add your Android/iOS apps to the Firebase project.
   - Download the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in their respective directories.
   - Enable Google Sign-In and Email/Password in the Firebase Authentication settings.
   - Set up Firestore rules.

4. **Run the App**
   ```bash
   flutter run
   ```

## Contributing 🤝

Check out the [Issues](https://github.com/your-username/your-repo/issues) page if you'd like to contribute or see the roadmap of upcoming features!
