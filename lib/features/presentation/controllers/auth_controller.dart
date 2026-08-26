import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Sign In with Google
  Future<String?> signInWithGoogle() async {
    _setLoading(true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in flow
        _setLoading(false);
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      _setLoading(false);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message;
    } catch (e) {
      _setLoading(false);
      return 'មិនអាចចូលគណនីតាម Google បានទេ (Google sign-in failed)';
    }
  }

  // Log Out (clears both Firebase session and Google session/token)
  Future<void> logout() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
