import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

// the type 3 (web) oauth client from google-services.json. android needs it to
// get an id token back. must match the firebase project.
const _serverClientId =
    '262499727053-pghpuugd124l55d9jglcr50d9hgjonrl.apps.googleusercontent.com';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  static bool _googleReady = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  // null means the user backed out, which is not an error.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // authenticate() is not supported on web, popup is the way there.
      if (kIsWeb) {
        return await _auth.signInWithPopup(GoogleAuthProvider());
      }
      if (!_googleReady) {
        await GoogleSignIn.instance.initialize(serverClientId: _serverClientId);
        _googleReady = true;
      }
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw AuthException('Google did not return a token. Try again.');
      }
      return await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw AuthException(_messageForGoogle(e));
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null || user.emailVerified) return;
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  Future<bool> refreshEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    // without this google keeps the account cached and the next sign in skips
    // the picker and silently reuses it.
    if (!kIsWeb && _googleReady) await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  String _messageForGoogle(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Sign in cancelled.';
      case GoogleSignInExceptionCode.interrupted:
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google sign in was interrupted. Try again.';
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google sign in is not set up correctly for this build.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'That was a different Google account. Try again.';
      case GoogleSignInExceptionCode.unknownError:
        return e.description ?? 'Google sign in failed.';
    }
  }

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email looks invalid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'account-exists-with-different-credential':
        return 'That email already has a password account. Sign in with your '
            'password instead.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a moment and try again.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }
}

// min 6 chars, one uppercase, one number, one special char
String? validatePassword(String? value) {
  final v = value ?? '';
  if (v.length < 6) return 'At least 6 characters';
  if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Add an uppercase letter';
  if (!RegExp(r'[0-9]').hasMatch(v)) return 'Add a number';
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\[\]\\/;+=~`]').hasMatch(v)) {
    return 'Add a special character';
  }
  return null;
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
