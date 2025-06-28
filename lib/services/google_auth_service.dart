import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static const List<String> _scopes = [
    'email',
    'profile',
  ];

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
  );

  /// Sign in with Google and return the ID token
  static Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        // User cancelled sign in
        return null;
      }

      final GoogleSignInAuthentication authentication =
          await account.authentication;

      return authentication.idToken;
    } catch (error) {
      print('Google Sign-In error: $error');
      return null;
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      print('Google Sign-Out error: $error');
    }
  }

  /// Check if user is currently signed in with Google
  static Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (error) {
      print('Google isSignedIn check error: $error');
      return false;
    }
  }

  /// Get current Google user (if signed in)
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return _googleSignIn.currentUser;
    } catch (error) {
      print('Get current Google user error: $error');
      return null;
    }
  }

  /// Disconnect Google account (revoke access)
  static Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      print('Google disconnect error: $error');
    }
  }
}
