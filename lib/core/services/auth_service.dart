import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  /// Returns null if Firebase has not been initialized.
  static bool get _firebaseReady {
    try {
      Firebase.app();
      return true;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth? get _auth => _firebaseReady ? FirebaseAuth.instance : null;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Current Auth user stream — emits null immediately when Firebase is unavailable
  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? Stream.value(null);

  User? get currentUser => _auth?.currentUser;

  // Sign in anonymously (Guest Mode)
  Future<UserCredential?> signInAnonymously() async {
    if (!_firebaseReady) return null;
    try {
      return await _auth!.signInAnonymously();
    } catch (e) {
      debugPrint('Error in signInAnonymously: $e');
      return null;
    }
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    if (!_firebaseReady) return null;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Cancelled by user

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth!.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error in signInWithGoogle: $e');
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth?.signOut();
    } catch (e) {
      debugPrint('Error in signOut: $e');
    }
  }
}
