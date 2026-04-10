import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen(this.error, {super.key});

  final GoException? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colors.secondaryContainer,

        leading: SizedBox(
          height: double.infinity,
          child: AspectRatio(
            aspectRatio: 1,
            child: IconButton(
              padding: .symmetric(horizontal: 8, vertical: 0),
              onPressed: () => context.go('/'),
              icon: PhosphorIcon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold)),
            ),
          ),
        ),

        title: const Text('TLDR News'),
      ),
      body: Center(
        child: Padding(
          padding: .all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hmm. An error occurred', style: Theme.of(context).textTheme.headlineMedium),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error?.message.capitalize() ?? error.toString(), textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
