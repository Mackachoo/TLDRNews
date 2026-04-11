import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

class Message {
  static void success(BuildContext context, String message) =>
      snackbar(context, message: 'Success: $message', color: context.colors.primary);

  static void info(BuildContext context, String message) => snackbar(context, message: message);

  static void error(BuildContext context, Object error) =>
      snackbar(context, message: 'There was an error: $error', color: context.colors.error);

  static void snackbar(BuildContext context, {required String message, Color? color}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
  }
}
