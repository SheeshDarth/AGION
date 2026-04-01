import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Helper to wrap Firebase Auth + Google Sign-In v7 operations.
/// All methods catch errors so the app doesn't crash when Firebase
/// is not configured.
class FirebaseAuthHelper {
  static FirebaseAuth? _auth;
  static bool _initialized = false;
  static bool _googleInitialized = false;

  /// Whether Firebase Auth is available.
  static bool get isAvailable => _initialized;

  /// Initialize. Call after Firebase.initializeApp succeeds.
  static Future<void> markInitialized() async {
    _initialized = true;
    _auth = FirebaseAuth.instance;
    // Initialize Google Sign-In (v7 API)
    try {
      await GoogleSignIn.instance.initialize();
      _googleInitialized = true;
    } catch (_) {
      _googleInitialized = false;
    }
  }

  /// Current Firebase user or null.
  static User? get currentUser => _auth?.currentUser;

  /// Sign in with Google (v7 API).
  /// Returns Firebase User or null.
  static Future<User?> signInWithGoogle() async {
    if (!_initialized || !_googleInitialized) return null;

    // Trigger Google interactive sign-in
    final GoogleSignInAccount googleUser =
        await GoogleSignIn.instance.authenticate();

    // Get the id token for Firebase credential
    final idToken = googleUser.authentication.idToken;

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );

    final userCredential = await _auth!.signInWithCredential(credential);
    return userCredential.user;
  }

  /// Sign out of both Firebase and Google.
  static Future<void> signOut() async {
    try {
      await _auth?.signOut();
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore
    }
  }
}
