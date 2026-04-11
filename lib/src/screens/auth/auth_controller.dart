import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tldrnews_app/src/objects/account/account.dart';
import 'package:tldrnews_app/src/objects/account/meta.dart';
import 'package:tldrnews_app/src/services/auth_service.dart';
import 'package:tldrnews_app/src/services/firestore_service.dart';
import 'package:tldrnews_app/src/utils/message.dart';

class AccountController with ChangeNotifier {
  static final AuthService _service = AuthService();
  late StreamSubscription<User?> authSub;

  AccountController() {
    authSub = AuthService.state.listen((User? user) async {
      if (user != null) {
        account = await FirestoreService.account.retrieve(user.uid);
        meta = await FirestoreService.meta.retrieve(user.uid);
      }
      notifyListeners();
    });
  }

  UserCredential? credential;
  User? get user => AuthService.currentUser;

  Account? account;
  Meta? meta;

  VoidCallback get signOut => AuthService.signOut;
  Future deleteAccount() async => AuthService.deleteAccount;

  @override
  void dispose() {
    authSub.cancel();
    super.dispose();
  }

  //* Main Methods ==============================================

  Future requestAuthentication(
    BuildContext context,
    Future<UserCredential?> Function() authenticator, {
    bool checkFormValid = false,
  }) async {
    if (checkFormValid && !formKey.currentState!.validate()) return Future.value(false);
    showLoading(context);
    try {
      credential = await authenticator();
      if (context.mounted) await initializeUser(context);
    } catch (e) {
      debugPrint('Failed to sign in: $e');
      if (context.mounted) reportError(context, e as Exception);
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future initializeUser(BuildContext context, {Map<String, bool>? consent}) async {
    try {
      showLoading(context);
      await FirestoreService.account.set(
        Account(
          uid: credential!.user!.uid,
          name: credential!.user!.displayName!,
          email: credential!.user!.email!,
          analyticsConsent: consent?['analytics'] ?? false,
          marketingConsent: consent?['marketing'] ?? false,
        ),
      );
    } catch (e) {
      debugPrint('AuthController.authSuccess: $e');
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void reportError(BuildContext context, Exception error, {String activity = 'logging in'}) {
    String errorCode = error is FirebaseAuthException
        ? error.code
        : error is GoogleSignInException
        ? error.code.name
        : 'default';
    if (context.mounted) {
      switch (errorCode) {
        case 'invalid-email':
          Message.error(context, 'Invalid email address');
          break;
        case 'email-already-in-use':
          Message.error(context, 'Email already in use');
          break;
        case 'weak-password':
          Message.error(context, 'Password is too weak');
          break;
        case 'invalid-credential':
          Message.error(context, 'Invalid credentials');
          break;
        default:
          Message.error(context, 'An error occurred');
          break;
      }
    }
  }

  Future<bool> resetEmail(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try {
        await _service.resetEmail(emailController.text.trim());
        if (context.mounted) {
          Message.error(context, 'Password reset email sent');
        }
        return true;
      } catch (e) {
        debugPrint('Failed to send password reset email: $e');
        if (context.mounted) {
          Message.error(context, 'Failed to send password reset email');
        }
      }
    }
    return false;
  }

  void clear() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  //* Authentication Methods =======================================

  // Email and password authentication
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  Future registerWithEmail(BuildContext context) async => await requestAuthentication(
    context,
    () async => await _service.registerWithEmail(
      emailController.text.trim(),
      passwordController.text.trim(),
    ),
    checkFormValid: true,
  );

  Future signInWithEmail(BuildContext context) async => await requestAuthentication(
    context,
    () async =>
        await _service.signInWithEmail(emailController.text.trim(), passwordController.text.trim()),
    checkFormValid: true,
  );

  // OAuth authentication
  Future signInWithGoogle(BuildContext context) async =>
      requestAuthentication(context, _service.signInWithGoogle);

  Future signInWithApple(BuildContext context) async =>
      requestAuthentication(context, _service.signInWithApple);

  //* Additional Methods ------------------------------------------

  void showLoading(BuildContext context) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(child: const CircularProgressIndicator()),
  );
}
