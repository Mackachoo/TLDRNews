import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';
import 'package:tldrnews_app/src/widgets/responsive_grid.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: .all(16),
        children: [
          Text('Admin Panel', style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: 16),
          ListTile(
            leading: PhosphorIcon(PhosphorIcons.userGear()),
            title: Text('Admins'),
            subtitle: Text('View and manage admins'),
            trailing: PhosphorIcon(PhosphorIcons.caretRight()),
            onTap: () => context.push('/admin/users'),
          ),
          SizedBox(height: 16),
          Container(
            color: context.colors.secondaryContainer,
            padding: .all(16),
            child: Column(
              spacing: 6,
              crossAxisAlignment: .start,
              children: [
                Text('Edit Channels', style: Theme.of(context).textTheme.headlineSmall),
                ResponsiveGrid(
                  physics: NeverScrollableScrollPhysics(),
                  alignment: .start,
                  minItemWidth: 120,
                  maxCrossAxisCount: 6,
                  children: ChannelSnippets.all
                      .map(
                        (c) => IconButton(
                          padding: .zero,
                          onPressed: () => context.push('/admin/channel/${c.id}'),
                          icon: c.icon,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
