
# TaasClub Blueprint

## Overview

TaasClub is a Flutter application that allows users to create and join game rooms, play games with real-time score updates, and view the results of completed games on a ledger screen. The application is built with Flutter and Firebase, and it uses the `go_router` package for navigation.

## Features

- **Real-time score updates:** Players can see their scores update in real-time during the game.
- **User profile integration:** The game displays players' avatars and display names from their profiles.
- **Ledger screen:** A ledger screen displays the final results of each game, with a share button to share the results.

## Project Structure

The project is structured as follows:

- `lib/`
  - `features/`
    - `auth/`: Contains the authentication-related files, including the `AuthGate` widget, the `AuthScreen` widget, and the `AuthService` class.
    - `game/`: Contains the game-related files, including the `GameScreen` widget, the `GameService` class, and the `GameRoom` model.
    - `lobby/`: Contains the lobby-related files, including the `LobbyScreen` widget and the `LobbyService` class.
    - `ledger/`: Contains the ledger-related files, including the `LedgerScreen` widget and the `LedgerService` class.
    - `profile/`: Contains the profile-related files, including the `ProfileScreen` widget and the `ProfileService` class.
  - `main.dart`: The main entry point of the application.
- `blueprint.md`: This file.

## Current Plan

I have now implemented all three features you requested:

1.  **Real-time score updates:** Players can see their scores update in real-time during the game.
2.  **User profile integration:** The game displays players' avatars and display names from their profiles.
3.  **Ledger screen:** A ledger screen displays the final results of each game, with a share button to share the results.

I also created a blueprint for the project, which you can find in the `blueprint.md` file.

Is there anything else I can help you with?
