import 'package:google_sign_in/google_sign_in.dart';

/// Wraps the google_sign_in package.
///
/// Returns a Google ID token string that the backend can verify via the
/// tokeninfo API. The token is a short-lived credential — we sign out of the
/// Google session immediately after extracting it so the app only maintains
/// the Edveo JWT, not a persistent Google session.
///
/// [serverClientId] MUST be the Web OAuth Client ID (not the Android or iOS
/// client ID). Without it, [GoogleSignInAccount.authentication.idToken] is
/// null on Android.
class GoogleAuthService {
  static const _webClientId =
      '513920000293-t2ftrugooud98kdmh06jkj6vtn11g8r2.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: ['email'],
  );

  /// Returns the Google ID token, or [null] if the user cancelled the picker.
  ///
  /// Throws [GoogleAuthException] on any configuration or platform error.
  Future<String?> getIdToken() async {
    try {
      // Sign out first to always show the account picker (no cached account).
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User dismissed the account picker — not an error.
        return null;
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken;

      if (idToken == null) {
        // This almost always means serverClientId is wrong or missing.
        throw const GoogleAuthException(
          'Google ID token is null. '
          'Verify that serverClientId is set to the Web OAuth Client ID.',
        );
      }

      // Sign out immediately — we only need the one-time ID token.
      // The Edveo JWT is the session credential; we don't want a persistent
      // Google session lingering in the app.
      await _googleSignIn.signOut();

      return idToken;
    } on GoogleAuthException {
      rethrow;
    } catch (e) {
      throw GoogleAuthException('Google Sign-In failed: $e');
    }
  }
}

class GoogleAuthException implements Exception {
  final String message;
  const GoogleAuthException(this.message);

  @override
  String toString() => 'GoogleAuthException: $message';
}
