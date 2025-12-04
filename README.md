# TaasClub 🎮

A Flutter game room application that allows users to create and join game rooms, track scores in real-time, and share results with friends.

## Features

- 🔐 **Firebase Authentication** - Anonymous sign-in for quick start
- 🎲 **Game Rooms** - Create and join multiplayer game rooms
- ⚡ **Real-time Scores** - Live score updates using Firestore
- 📊 **Game History** - View past games and results
- 🏆 **Leaderboard** - See top players ranked by score
- 👤 **User Profiles** - Customize display name and avatar
- 📤 **Share Results** - Share game results with friends

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Firebase** - Backend services
  - Firestore (database)
  - Authentication
  - Storage (avatars)
- **Riverpod** - State management
- **go_router** - Navigation
- **Freezed** - Immutable data classes
- **Google Fonts** - Material 3 typography

## Getting Started

### Prerequisites

- Flutter SDK ^3.9.0
- Firebase CLI
- A Firebase project

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/timecapsulellc/TaasClub.git
   cd TaasClub
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   ```bash
   flutterfire configure
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── features/
│   ├── auth/           # Authentication screens and services
│   ├── game/           # Game room, scores, and history
│   ├── ledger/         # Completed game results
│   ├── lobby/          # Game room listing and creation
│   └── profile/        # User profile management
├── firebase_options.dart
└── main.dart
```

## Firebase Setup

The app uses the following Firebase services:

- **Firestore Collections:**
  - `games` - Active and completed game rooms
  - `users` - User profiles

- **Security Rules:** Configured for authenticated access only

## Development

### Run with hot reload:
```bash
flutter run
```

### Generate Freezed files:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Deploy Firestore rules:
```bash
firebase deploy --only firestore:rules
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is private and proprietary.

## Contact

For questions or support, please contact the development team.

