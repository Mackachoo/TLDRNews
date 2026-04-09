import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.state});

  final Widget child;
  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: appBar(context),
      bottomNavigationBar: orientation == .portrait ? navbar(context) : null,
      body: Row(
        children: [
          if (orientation == .landscape) navbar(context),
          Expanded(
            child: Container(
              alignment: .topCenter,
              constraints: BoxConstraints(maxWidth: 800),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  static AppBar appBar(BuildContext context) {
    final route = GoRouterState.of(context).uri.toString();
    final title = route.contains('/channel/')
        ? ChannelSnippets.byId(route.split('/channel/').last)?.name ?? 'TLDR News'
        : 'TLDR News';

    return AppBar(
      backgroundColor: context.colors.secondaryContainer,
      leadingWidth: 96,
      leading: IconButton(
        padding: .symmetric(horizontal: 8, vertical: 0),
        onPressed: () => context.go('/'),
        icon: Image.asset('assets/logos/tldr-white.png', height: double.infinity),
      ),
      title: Text(title),
      actions: [
        if (route == '/settings')
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold)),
            onPressed: () => context.pop(),
          )
        else
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.gear(PhosphorIconsStyle.bold)),
            onPressed: () => context.push('/settings'),
          ),
      ],
    );
  }

  static Widget navbar(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final route = GoRouterState.of(context).uri.toString();
    final active = route.contains('/channel/') ? route.split('/channel/').last : null;
    if (route == '/') return SizedBox.shrink();

    return Container(
      color: context.colors.secondaryFixedDim,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8),
          width: orientation == .landscape ? 96 : double.infinity,
          height: orientation == .portrait ? 96 : double.infinity,
          child: ListView.separated(
            scrollDirection: orientation == .portrait ? Axis.horizontal : Axis.vertical,
            separatorBuilder: (context, index) => const SizedBox.square(dimension: 8),
            itemCount: ChannelSnippets.all.length,
            itemBuilder: (context, index) {
              return ChannelSnippets.buttons(context, active)[index];
            },
          ),
        ),
      ),
    );
  }
}
