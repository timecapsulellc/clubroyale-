
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_config.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Mock user for test mode - stored globally
class TestUser {
  static String? uid;
  static String? displayName;
  static String? email;

  static void generate({String? name}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    uid = 'test_user_$timestamp';
    displayName = name ?? 'Test Player';
    email = 'testplayer_$timestamp@taasclub.test';
  }

  static void clear() {
    uid = null;
    displayName = null;
    email = null;
  }
}

/// TestMode flag with reactive notifier
class TestMode {
  static final ValueNotifier<bool> _notifier = ValueNotifier(false);
  
  static ValueNotifier<bool> get notifier => _notifier;
  
  static bool get isEnabled => _notifier.value;
  
  static set isEnabled(bool value) {
    _notifier.value = value;
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Returns the current user (Firebase or Mock)
  User? get currentUser {
    // If test mode is active and we have a test user
    if (TestMode.isEnabled && TestUser.uid != null) {
      return _TestModeUser();
    }
    return _auth.currentUser;
  }

  /// Check if currently in test mode
  bool get isTestMode => TestMode.isEnabled;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Setup FCM for push notifications
  Future<void> _setupFCM(String uid) async {
    try {
      if (kIsWeb) {
        // Request permission
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
           // Get token
           final token = await FirebaseMessaging.instance.getToken(
             vapidKey: FirebaseConfig.vapidKey,
           );
           
           if (token != null) {
             debugPrint('🔥 FCM Token: $token');
             // Save to Firestore
             await FirebaseFirestore.instance
                 .collection('users')
                 .doc(uid)
                 .collection('fcmTokens')
                 .doc(token)
                 .set({
               'token': token,
               'createdAt': FieldValue.serverTimestamp(),
               'platform': kIsWeb ? 'web' : 'mobile',
             });
           }
        }
      }
    } catch (e) {
      debugPrint('Error setting up FCM: $e');
    }
  }

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google User Credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Clear test mode if active
      if (TestMode.isEnabled) {
        TestMode.isEnabled = false;
        TestUser.clear();
      }
      
      // Setup FCM after successful login
      if (userCredential.user != null) {
        await _setupFCM(userCredential.user!.uid);
      }
      
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return null;
    }
  }

  /// Sign in anonymously - tries Firebase first, falls back to test mode
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      
      // Setup FCM after successful login
      if (userCredential.user != null) {
        await _setupFCM(userCredential.user!.uid);
      }
      
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      
      // Auto-enable test mode if Firebase auth fails
      debugPrint('💡 Firebase Auth failed. Enabling Test Mode...');
      return await enableTestMode();
    }
  }

  /// Enable test mode and create a mock user
  Future<User?> enableTestMode({String? playerName}) async {
    debugPrint('🧪 Enabling Test Mode...');
    
    // Create mock user
    TestUser.generate(name: playerName ?? 'Test Player');
    TestMode.isEnabled = true;
    
    debugPrint('✅ Test Mode enabled! User: ${TestUser.displayName} (${TestUser.uid})');
    
    return _TestModeUser();
  }

  /// Sign out (handles both Firebase and test mode)
  Future<void> signOut() async {
    if (TestMode.isEnabled) {
      // Clear test mode
      TestMode.isEnabled = false;
      TestUser.clear();
      debugPrint('🧪 Test Mode disabled');
    }
    
    try {
      await _googleSignIn.signOut(); // Sign out from Google
      await _auth.signOut();
    } catch (e) {
      debugPrint('Firebase signOut error (ignored in test mode): $e');
    }
  }
}

/// A mock User class for test mode
class _TestModeUser implements User {
  @override
  String get uid => TestUser.uid ?? 'test_user';

  @override
  String? get displayName => TestUser.displayName;

  @override
  String? get email => TestUser.email;

  @override
  bool get emailVerified => true;

  @override
  bool get isAnonymous => true;

  @override
  UserMetadata get metadata => throw UnimplementedError();

  @override
  MultiFactor get multiFactor => throw UnimplementedError();

  @override
  String? get phoneNumber => null;

  @override
  String? get photoURL => null;

  @override
  List<UserInfo> get providerData => [];

  @override
  String? get refreshToken => null;

  @override
  String? get tenantId => null;

  // Implement required methods with stubs
  @override
  Future<void> delete() async {}

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => 'mock_token';

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> reauthenticateWithProvider(AuthProvider provider) {
    throw UnimplementedError();
  }

  @override
  Future<void> reload() async {}

  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) async {}

  @override
  Future<User> unlink(String providerId) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateDisplayName(String? displayName) async {}

  Future<void> updateEmail(String newEmail) async {}

  Future<void> updatePassword(String newPassword) async {}

  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {}

  @override
  Future<void> updatePhotoURL(String? photoURL) async {}

  Future<void> updateProfile({String? displayName, String? photoURL}) async {}

  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) async {}

  @override
  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber, [RecaptchaVerifier? verifier]) {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> linkWithPopup(AuthProvider provider) {
    throw UnimplementedError();
  }

  @override
  Future<void> linkWithRedirect(AuthProvider provider) {
    throw UnimplementedError();
  }

  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) {
    throw UnimplementedError();
  }

  Future<void> reauthenticateWithRedirect(AuthProvider provider) {
    throw UnimplementedError();
  }
}
