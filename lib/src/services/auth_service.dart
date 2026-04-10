import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static Stream<User?> get state => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;

  //* General authentication methods
  static Future<void> signOut() async => await _auth.signOut();
  static Future<void> deleteAccount() async => await currentUser!.delete();

  //* Email and password authentication
  Future<UserCredential> signInWithEmail(String email, String password) async =>
      await _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> registerWithEmail(String email, String password) async =>
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> resetEmail(String email) async => await _auth.sendPasswordResetEmail(email: email);

  //* OAuth authentication
  GoogleSignIn? _googleSignIn;

  Future<bool> _checkGoogleSignIn() async {
    try {
      if (kIsWeb) {
        throw UnsupportedError('Web platform requires different sign-in flow');
      }
      if (_googleSignIn != null) return true;

      await GoogleSignIn.instance.initialize();
      _googleSignIn = GoogleSignIn.instance;
      return true;
    } catch (e) {
      debugPrint('Failed to initialize Google Sign-In: $e');
    }
    return false;
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      }

      if (!await _checkGoogleSignIn()) {
        throw Exception('Google Sign-In failed to initialize');
      }

      // Authenticate with Google
      final GoogleSignInAccount googleUser = await _googleSignIn!.authenticate(
        scopeHint: ['email'],
      );

      // Get authorization for Firebase scopes if needed
      final authClient = _googleSignIn!.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email']);

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      debugPrint(
        'Google Sign In Error: ${e.code.name} description:${e.description} details:${e.details}',
      );
      rethrow;
    } catch (error) {
      debugPrint('Unexpected Google Sign-In error: $error');
      rethrow;
    }
  }

  Future<UserCredential> signInWithApple() async {
    if (kIsWeb) {
      // Web implementation
      final provider = OAuthProvider('apple.com');
      provider.addScope('email');
      provider.addScope('name');

      // Sign in with a popup
      return await _auth.signInWithPopup(provider);
    } else {
      // Mobile implementation
      final appleAuthProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      // Sign in with Firebase
      return await _auth.signInWithProvider(appleAuthProvider);
    }
  }
}
