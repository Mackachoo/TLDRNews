import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tldrnews_app/src/objects/account/account.dart';
import 'package:tldrnews_app/src/objects/account/meta.dart';
import 'package:tldrnews_app/src/services/auth_service.dart';
import 'package:tldrnews_app/src/services/firestore_service.dart';
import 'package:tldrnews_app/src/utils/message.dart';

/// Auth state and sign-in flows.
///
/// Follows Firebase's auth stream, loading [account] and [meta] on every change
/// and notifying listeners. Also owns the shared email form controllers.
class AuthController with ChangeNotifier {
  static final AuthService _service = AuthService();
  late StreamSubscription<User?> authSub;

  AuthController() {
    authSub = AuthService.state.listen((User? user) async {
      try {
        if (user != null) {
          account = await FirestoreService.account.retrieve(user.uid);
          meta = await FirestoreService.meta.retrieve(user.uid);
        } else {
          account = null;
          meta = null;
        }
      } catch (e) {
        debugPrint('AuthController: Failed to retrieve account data: $e');
      } finally {
        resolved = true;
        notifyListeners();
      }
    });
  }

  /// False until the first auth state has been read. Route guards must wait for
  /// this, otherwise a deep link is judged against a signed-out state.
  bool resolved = false;

  /// Credential from the latest sign-in in this session.
  UserCredential? credential;

  /// The Firebase user, or `null` when signed out.
  User? get user => AuthService.currentUser;

  /// The user's profile, or `null` when signed out.
  Account? account;

  /// The user's permissions, or `null` when signed out.
  Meta? meta;

  VoidCallback get signOut => AuthService.signOut;
  Future deleteAccount() async => AuthService.deleteAccount;

  @override
  void dispose() {
    authSub.cancel();
    super.dispose();
  }

  //* Main Methods ==============================================

  /// Runs [authenticator] behind a loading dialog, then creates the account
  /// document. Failures are shown as a message. With [checkFormValid], does
  /// nothing unless the form validates.
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

  /// Reloads the Firebase user, [account] and [meta], e.g. after a membership
  /// change.
  Future refresh() async {
    try {
      await AuthService.currentUser?.reload();
      account = await FirestoreService.account.retrieve(AuthService.currentUser!.uid);
      meta = await FirestoreService.meta.retrieve(AuthService.currentUser!.uid);
      notifyListeners();
    } catch (e) {
      debugPrint('AuthController.refresh: Failed to refresh auth state: $e');
    }
  }

  /// Writes the account document for the signed-in [credential], recording the
  /// optional [consent] choices (`analytics`, `marketing`).
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

  /// Shows a friendly message for the Firebase or Google error code in [error].
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

  /// Sends a password reset email to the address in the form. Returns whether
  /// it was sent.
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

  /// Empties the email and password fields.
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

  /// Shows a blocking spinner dialog; dismiss it by popping the root navigator.
  void showLoading(BuildContext context) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(child: const CircularProgressIndicator()),
  );
}
