import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Result returned by a successful Google Sign-In flow.
class GoogleSignInResult {
  /// The Google ID token (JWT) to pass to the backend OAuth endpoint.
  final String idToken;

  /// The user's Google email address (for display only).
  final String email;

  /// The user's Google display name (for display only).
  final String? displayName;

  /// Creates a [GoogleSignInResult].
  const GoogleSignInResult({
    required this.idToken,
    required this.email,
    this.displayName,
  });
}

/// Wraps the [GoogleSignIn] package for use in the auth flow.
///
/// Call [signIn] when the user taps "Continue with Google".
/// On success pass [GoogleSignInResult.idToken] to
/// [AuthController.oauthLogin] with provider `'google'`.
///
/// TODO: Set [GoogleSignIn.serverClientId] once the backend team
/// provides the Google OAuth web client ID.
class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    // TODO: Uncomment and set once backend provides client ID:
    // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
  );

  /// Triggers the Google Sign-In UI.
  ///
  /// Returns [GoogleSignInResult] on success, or `null` if the
  /// user dismissed the dialog without signing in.
  ///
  /// Throws [GoogleSignInException] if authentication succeeds
  /// but no ID token is returned.
  Future<GoogleSignInResult?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null; // User cancelled.

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        throw const GoogleSignInException(
          'Google authentication returned no ID token. '
          'Ensure serverClientId is configured.',
        );
      }

      return GoogleSignInResult(
        idToken: idToken,
        email: account.email,
        displayName: account.displayName,
      );
    } catch (e) {
      debugPrint('GoogleSignInService.signIn error: $e');
      rethrow;
    }
  }

  /// Signs the user out of their Google account.
  ///
  /// Call alongside [AuthController.logout].
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('GoogleSignInService.signOut error: $e');
    }
  }

  /// Revokes all Google permissions (use on account deletion).
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint('GoogleSignInService.disconnect error: $e');
    }
  }
}

/// Thrown when the Google Sign-In flow returns unusable data.
class GoogleSignInException implements Exception {
  /// A description of what went wrong.
  final String message;

  /// Creates a [GoogleSignInException].
  const GoogleSignInException(this.message);

  @override
  String toString() => 'GoogleSignInException: $message';
}
