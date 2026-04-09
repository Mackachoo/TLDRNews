import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tldrnews_app/src/objects/channel.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title = 'TLDR News',
    this.includeNavbar = true,
    this.appbarBottom,
  });

  final Widget body;
  final String title;
  final bool includeNavbar;
  final PreferredSizeWidget? appbarBottom;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: appBar(context),
      bottomNavigationBar: orientation == .portrait && includeNavbar == true
          ? navbar(context)
          : null,
      body: Row(
        children: [
          if (orientation == .landscape && includeNavbar == true) navbar(context),
          Expanded(
            child: Container(
              alignment: .topCenter,
              constraints: BoxConstraints(maxWidth: 800),
              child: Padding(padding: .all(16), child: body),
            ),
          ),
        ],
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    final route = GoRouterState.of(context).uri.toString();

    return AppBar(
      key: Key('appbar'),
      leading: IconButton(
        onPressed: () => context.go('/'),
        icon: Image.asset('assets/logos/tldr-white.png'),
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
      bottom: appbarBottom,
    );
  }

  Widget navbar(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final route = GoRouterState.of(context).uri.toString();
    final active = route.contains('/channel/') ? route.split('/channel/').last : null;

    return Hero(
      tag: 'navbar',
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8),
          width: orientation == .landscape ? 96 : double.infinity,
          height: orientation == .portrait ? 96 : double.infinity,
          child: ListView(
            scrollDirection: orientation == .portrait ? Axis.horizontal : Axis.vertical,

            children: Channels.buttons(context, active),
          ),
        ),
      ),
    );
  }
}
