import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Result of a Google Sign-In attempt
class SocialAuthResult {
  final String idToken;
  final String name;
  final String email;
  final String? photoUrl;

  SocialAuthResult({
    required this.idToken,
    required this.name,
    required this.email,
    this.photoUrl,
  });
}

class SocialAuthService {
  static final SocialAuthService _instance = SocialAuthService._internal();
  factory SocialAuthService() => _instance;
  SocialAuthService._internal();

  // IMPORTANT: serverClientId must be the WEB Client ID (not Android Client ID).
  // This is required for google_sign_in to return an idToken.
  // The Android Client ID is used automatically based on SHA-1 fingerprint.
  static const String _serverClientId =
      '757551348521-1l0vb63sdgckau8380t1k8lldr19g9p1.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: _serverClientId,
  );

  /// Trigger Google Sign-In flow.
  /// Returns [SocialAuthResult] with id_token, name, email on success.
  /// Returns null if user cancelled or there was an error.
  Future<SocialAuthResult?> signInWithGoogle() async {
    try {
      // Sign out first to always show account picker
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        // User cancelled the sign-in
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      if (auth.idToken == null) {
        debugPrint('Google Sign-In: id_token is null — check that serverClientId (Web Client ID) is correct');
        return null;
      }

      return SocialAuthResult(
        idToken: auth.idToken!,
        name: account.displayName ?? account.email.split('@').first,
        email: account.email,
        photoUrl: account.photoUrl,
      );
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      return null;
    }
  }

  /// Sign out of Google (used when user logs out of the app)
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google Sign-Out error: $e');
    }
  }
}
