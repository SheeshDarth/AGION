import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/firebase_auth_helper.dart';

/// Authentication state.
class AuthState {
  final bool isSignedIn;
  final bool isGuest;
  final String? uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isSignedIn = false,
    this.isGuest = false,
    this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isSignedIn,
    bool? isGuest,
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isSignedIn: isSignedIn ?? this.isSignedIn,
      isGuest: isGuest ?? this.isGuest,
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  factory AuthState.guest() => const AuthState(
        isSignedIn: true,
        isGuest: true,
        uid: 'guest',
        displayName: 'Hunter',
      );
}

// ─── PROVIDER ──────────────────────────────────────────────────────────────

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  /// Check if user is already signed in.
  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = FirebaseAuthHelper.currentUser;
      if (user != null) {
        state = AuthState(
          isSignedIn: true,
          uid: user.uid,
          displayName: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
        );
        return;
      }
    } catch (_) {
      // Firebase not available
    }
    state = state.copyWith(isLoading: false);
  }

  /// Google Sign-In flow.
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await FirebaseAuthHelper.signInWithGoogle();
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = AuthState(
        isSignedIn: true,
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().contains('network_error')
            ? 'No internet connection'
            : 'Sign-in failed. Check Firebase config.',
      );
    }
  }

  /// Guest mode — fully offline, no cloud sync.
  void continueAsGuest() {
    state = AuthState.guest();
  }

  /// Sign out and return to login.
  Future<void> signOut() async {
    await FirebaseAuthHelper.signOut();
    state = const AuthState();
  }
}
