import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ── Google OAuth setup ────────────────────────────────────────────────────────
//
// WHAT YOU NEED FROM THE BACKEND TEAM:
//   - The Web Client ID from Google Cloud Console
//     (format: XXXXXXXXXXXX-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com)
//
// WHAT YOU NEED TO DO YOURSELF:
//   - Generate your debug SHA-1 fingerprint and add it to the Google Cloud
//     Console under your Android OAuth client:
//
//     Windows:
//       keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
//
//     Mac/Linux:
//       keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
//
//   - Copy the SHA1 fingerprint from the output and add it in:
//     Google Cloud Console → APIs & Services → Credentials
//     → Your Android OAuth 2.0 Client → SHA-1 certificate fingerprints
//
// HOW TO COMPLETE THE SETUP:
//   1. Get the Web Client ID from backend.
//   2. Uncomment the serverClientId line below and fill it in.
//   3. Set _kServerClientId to the actual value.
//   4. Run: flutter clean && flutter pub get
//
// Until then, sign-in will succeed but idToken will be null, and
// GoogleSignInException will be thrown (caught gracefully by the controller).

// Uncomment and fill in once backend provides the client ID:
// const String _kServerClientId =
//     'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

/// Result returned by a successful Google Sign-In flow.
class GoogleSignInResult {
  /// The Google ID token (JWT) to POST to the backend OAuth endpoint.
  final String idToken;

  /// The user's Google email address (for display only, not trusted).
  final String email;

  /// The user's Google display name (for display only).
  final String? displayName;

  const GoogleSignInResult({
    required this.idToken,
    required this.email,
    this.displayName,
  });
}

/// Wraps [GoogleSignIn] for use in the auth flow.
///
/// Responsibilities:
///   1. Open the native Google account selector.
///   2. Extract the ID token (JWT) from the result.
///   3. Return [GoogleSignInResult] to the caller (AuthController).
///
/// The caller (AuthController.loginWithGoogle) passes the idToken to
/// OAuthLoginUseCase which POSTs it to your backend's /auth/google endpoint.
/// The backend verifies it with Google and issues your own JWT pair.
class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // TODO: Uncomment once backend provides Web Client ID:
    // serverClientId: _kServerClientId, --> to know from Amir
  );

  /// Triggers the Google Sign-In UI.
  ///
  /// Returns [GoogleSignInResult] on success.
  /// Returns null if the user dismissed the dialog without signing in.
  /// Throws [GoogleSignInException] if authentication succeeds but the
  /// ID token is missing (happens when serverClientId is not configured).
  Future<GoogleSignInResult?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null; // User cancelled.

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        // This happens when serverClientId is not set. The token is required
        // for backend verification — sign-in cannot proceed without it.
        throw const GoogleSignInException(
          'Google authentication returned no ID token.\n'
          'Action required: set serverClientId in google_sign_in_service.dart\n'
          'with the Web Client ID provided by your backend team.',
        );
      }

      return GoogleSignInResult(
        idToken: idToken,
        email: account.email,
        displayName: account.displayName,
      );
    } on GoogleSignInException {
      rethrow;
    } catch (e) {
      debugPrint('GoogleSignInService.signIn error: $e');
      rethrow;
    }
  }

  /// Signs the user out of their Google account on this device.
  /// Call alongside AuthController.logout().
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('GoogleSignInService.signOut error: $e');
    }
  }

  /// Revokes all Google permissions.
  /// Call when the user deletes their account.
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
  final String message;
  const GoogleSignInException(this.message);

  @override
  String toString() => 'GoogleSignInException: $message';
}
