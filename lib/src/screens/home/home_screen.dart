import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';
import 'package:tldrnews_app/src/widgets/responsive_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surface,
      child: ListView(
        padding: .all(16),
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
                ResponsiveGrid(
                  physics: NeverScrollableScrollPhysics(),
                  minItemWidth: 120,
                  maxCrossAxisCount: 6,
                  children: ChannelSnippets.buttons(
                    context,
                    onTap: (id) => context.go('/channel/$id'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
