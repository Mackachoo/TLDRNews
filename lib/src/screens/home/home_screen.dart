import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/app_shell.dart';
import 'package:tldrnews_app/src/screens/screen.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

class HomeScreen extends StatelessWidget implements Screen {
  const HomeScreen({super.key});

  @override
  AppBar? get appbar => null;
  @override
  Widget? get navbar => SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: .center,
      constraints: BoxConstraints(maxWidth: 800),
      child: Padding(
        padding: .all(16),
        child: Column(
          spacing: 4,
          crossAxisAlignment: .start,
          children: [
            Text('Welcome to TLDR News!', style: Theme.of(context).textTheme.headlineMedium),
            Text(
              'Making news accessible for everyone.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            Container(
              color: context.colors.secondaryContainer,
              padding: .all(16),
              child: Column(
                spacing: 6,
                crossAxisAlignment: .start,
                children: [
                  Text('Our Channels', style: Theme.of(context).textTheme.headlineSmall),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    children: AppShell.channelButtons(context, null),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
