import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';
import 'package:tldrnews_app/src/widgets/responsive_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final channels = App.ctlr.auth.meta?.channels ?? ChannelSnippets.free;
    final buttons = channels
        .map((c) => c.button(context, onTap: (id) => context.go('/channel/$id')))
        .toList();

    return Container(
      color: context.colors.surface,
      child: ListView(
        padding: .all(16),
        children: [
          Text('Welcome to TLDR News!', style: Theme.of(context).textTheme.headlineMedium),
          Text(
            '''TLDR News is an independent online media group that focuses on making digital content about news and current affairs from all over the world.

We pride ourselves on our accessible, non-partisan, and impartial coverage of current events – aimed to help young people better understand the world around them, and form their own opinions.''',
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
                  children: buttons,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
