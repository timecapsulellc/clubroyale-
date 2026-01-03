/// Custom exceptions for ClubRoyale game operations
library;

/// Base exception for all game-related errors
class GameException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  GameException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'GameException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for network-related errors
class NetworkException extends GameException {
  NetworkException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception for invalid game state or moves
class InvalidMoveException extends GameException {
  InvalidMoveException(super.message, {super.code});

  @override
  String toString() => 'InvalidMoveException: $message';
}

/// Exception for Firebase-related errors
class FirebaseGameException extends GameException {
  FirebaseGameException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'FirebaseGameException: $message';
}

/// Exception for authentication errors
class AuthenticationException extends GameException {
  AuthenticationException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'AuthenticationException: $message';
}
