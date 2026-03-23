import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ── Google OAuth setup ────────────────────────────────────────────────────────
//
// WHAT YOU NEED FROM THE BACKEND TEAM:
//   1. The Web Client ID (serverClientId) from Google Cloud Console.
//      Format: XXXXXXXXXXXX-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
//      This is REQUIRED — without it serverAuthCode will be null.
//
//   2. Your test email added to Google Cloud Console as a Test User.
//      During development only test emails can authenticate.
//
// WHAT YOU NEED TO DO YOURSELF:
//   Generate your debug SHA-1 fingerprint and give it to the backend team
//   so they can register the Android OAuth client:
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
//   2. Replace 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com' below.
//   3. Run: flutter clean && flutter pub get
//
// ─────────────────────────────────────────────────────────────────────────────
// The Tunify backend uses the AUTHORIZATION CODE FLOW.
// This means we extract account.serverAuthCode
// The serverAuthCode is sent to the backend which exchanges it with Google.
//
// serverAuthCode is ONLY available when serverClientId is set correctly.
// ─────────────────────────────────────────────────────────────────────────────

// Actual Web Client ID from backend:
const String _kServerClientId =
    '1017429885522-kl4im9el69ojobga604qnjbjm1lo1c20.apps.googleusercontent.com';

/// Result returned by a successful Google Sign-In flow.
class GoogleSignInResult {
  /// The authorization code to POST to the Tunify backend.
  /// Backend exchanges this with Google to get tokens.
  /// Expires in ~60 seconds — send to backend immediately.
  final String authorizationCode;

  /// The user's Google email (for display only).
  final String email;

  /// The user's Google display name (for display only).
  final String? displayName;

  const GoogleSignInResult({
    required this.authorizationCode,
    required this.email,
    this.displayName,
  });
}

/// Wraps [GoogleSignIn] for use in the auth flow.
///
/// Uses the authorization code flow as required by the Tunify backend.
/// The serverAuthCode from Google is sent to POST /auth/google.
/// Backend exchanges it, creates/finds the user, returns JWT pair.
class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    serverClientId: _kServerClientId, // Required for serverAuthCode
  );

  /// Triggers the Google Sign-In UI.
  ///
  /// Returns [GoogleSignInResult] containing the authorization code on success.
  /// Returns null if the user dismissed the dialog without signing in.
  /// Throws [GoogleSignInException] if sign-in succeeds but serverAuthCode
  /// is null (happens when serverClientId is not configured correctly).
  Future<GoogleSignInResult?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null; // User cancelled.

      // serverAuthCode is the authorization code the backend needs.
      // It is ONLY populated when serverClientId is set correctly.
      final serverAuthCode = account.serverAuthCode;

      if (serverAuthCode == null) {
        throw const GoogleSignInException(
          'Google Sign-In returned no serverAuthCode.\n'
          'Ensure _kServerClientId is set to the correct Web Client ID\n'
          'from Google Cloud Console (not the Android/iOS client ID).',
        );
      }

      return GoogleSignInResult(
        authorizationCode: serverAuthCode,
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
