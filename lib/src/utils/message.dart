import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

/// Snackbar helpers for reporting outcomes to the user.
class Message {
  /// Primary-coloured snackbar prefixed with "Success:".
  static void success(BuildContext context, String message) =>
      snackbar(context, message: 'Success: $message', color: context.colors.primary);

  /// Plain snackbar.
  static void info(BuildContext context, String message) => snackbar(context, message: message);

  /// Error-coloured snackbar showing [error].
  static void error(BuildContext context, Object error) =>
      snackbar(context, message: 'There was an error: $error', color: context.colors.error);

  /// Snackbar with selectable text, optionally on a [color].
  static void snackbar(BuildContext context, {required String message, Color? color}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: color, content: SelectableText(message)));
  }
}
