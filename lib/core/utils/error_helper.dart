/// Centralized error message parsing for consistent UX
///
/// Converts technical error messages into user-friendly text
library;

/// Parse error messages and return user-friendly text
/// 
/// Usage:
/// ```dart
/// catch (e) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(ErrorHelper.getFriendlyMessage(e))),
///   );
/// }
/// ```
class ErrorHelper {
  /// Convert any error to a user-friendly message
  static String getFriendlyMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    // Network errors
    if (errorStr.contains('socket') || 
        errorStr.contains('network') ||
        errorStr.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    }
    
    // Timeout errors
    if (errorStr.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    // Firebase Auth errors
    if (errorStr.contains('invalid-credential') ||
        errorStr.contains('wrong-password')) {
      return 'Invalid credentials. Please check and try again.';
    }
    if (errorStr.contains('user-not-found')) {
      return 'Account not found. Please sign up first.';
    }
    if (errorStr.contains('email-already-in-use')) {
      return 'This email is already registered. Try signing in instead.';
    }
    if (errorStr.contains('weak-password')) {
      return 'Password is too weak. Please use a stronger password.';
    }
    if (errorStr.contains('unauthenticated')) {
      return 'Please sign in to continue.';
    }
    
    // Firestore errors
    if (errorStr.contains('permission-denied')) {
      return 'You don\'t have permission for this action.';
    }
    if (errorStr.contains('not-found')) {
      return 'The requested item was not found.';
    }
    if (errorStr.contains('already-exists')) {
      return 'This item already exists.';
    }
    if (errorStr.contains('unavailable')) {
      return 'Service temporarily unavailable. Please try again later.';
    }
    if (errorStr.contains('resource-exhausted')) {
      return 'Too many requests. Please wait a moment and try again.';
    }
    
    // Game-specific errors
    if (errorStr.contains('insufficient') && errorStr.contains('diamond')) {
      return '💎 Not enough diamonds for this action.';
    }
    if (errorStr.contains('room') && errorStr.contains('full')) {
      return 'This room is full. Try another room.';
    }
    if (errorStr.contains('game') && errorStr.contains('started')) {
      return 'The game has already started.';
    }
    if (errorStr.contains('not your turn')) {
      return 'Please wait for your turn.';
    }
    if (errorStr.contains('invalid') && errorStr.contains('move')) {
      return 'Invalid move. Please try a different action.';
    }
    if (errorStr.contains('bot')) {
      return 'Unable to add bot player. Please try again.';
    }
    
    // Room/Lobby errors
    if (errorStr.contains('room') && errorStr.contains('not found')) {
      return 'Room not found. It may have been deleted.';
    }
    if (errorStr.contains('leave') || errorStr.contains('left')) {
      return 'Unable to leave room. Please try again.';
    }
    
    // Transaction errors
    if (errorStr.contains('failed-precondition')) {
      return 'Cannot complete this action right now. Please try again.';
    }
    if (errorStr.contains('aborted')) {
      return 'Action was cancelled. Please try again.';
    }
    
    // Generic fallback - try to extract readable message
    return _extractReadableMessage(error.toString());
  }
  
  /// Extract readable portion from error message
  static String _extractReadableMessage(String error) {
    // Remove common prefixes
    var cleaned = error
        .replaceAll('Exception:', '')
        .replaceAll('FirebaseException:', '')
        .replaceAll('[firebase_auth/', '')
        .replaceAll('[cloud_firestore/', '')
        .replaceAll(']', '')
        .trim();
    
    // Try to extract message after common delimiters
    if (cleaned.contains(':')) {
      final parts = cleaned.split(':');
      if (parts.length > 1 && parts.last.trim().length > 5) {
        cleaned = parts.last.trim();
      }
    }
    
    // Capitalize first letter
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }
    
    // Return generic if still looks technical
    if (cleaned.length > 100 || 
        cleaned.contains('stack') || 
        cleaned.contains('null') ||
        cleaned.contains('Error at')) {
      return 'Something went wrong. Please try again.';
    }
    
    return cleaned.isEmpty 
        ? 'Something went wrong. Please try again.' 
        : cleaned;
  }
  
  /// Get error type for analytics/logging
  static String getErrorType(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('network') || errorStr.contains('socket')) {
      return 'network';
    }
    if (errorStr.contains('permission') || errorStr.contains('auth')) {
      return 'permission';
    }
    if (errorStr.contains('not-found')) {
      return 'not_found';
    }
    if (errorStr.contains('game') || errorStr.contains('room')) {
      return 'game';
    }
    if (errorStr.contains('diamond') || errorStr.contains('wallet')) {
      return 'wallet';
    }
    
    return 'unknown';
  }
}
