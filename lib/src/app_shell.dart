import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tldrnews_app/src/objects/channel.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    this.title = 'TLDR News',
    this.includeNavbar = true,
    this.appbarBottom,
  });

  final Widget child;
  final String title;
  final bool includeNavbar;
  final PreferredSizeWidget? appbarBottom;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: appBar(context, title: title, bottom: appbarBottom),
      bottomNavigationBar: orientation == .portrait && includeNavbar == true
          ? navbar(context)
          : null,
      body: Row(
        children: [
          if (orientation == .landscape && includeNavbar == true) navbar(context),
          Expanded(
            child: Container(
              alignment: .center,
              constraints: BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                child: Padding(padding: .all(16), child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar appBar(BuildContext context, {String? title, PreferredSizeWidget? bottom}) {
    final route = GoRouterState.of(context).uri.toString();

    return AppBar(
      leading: IconButton(
        onPressed: () => context.go('/'),
        icon: Image.asset('assets/logos/tldr-white.png'),
      ),
      title: Text(title ?? 'TLDR News'),
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
      bottom: bottom,
    );
  }

  static Widget navbar(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final route = GoRouterState.of(context).uri.toString();
    final active = route.contains('/channel/') ? route.split('/channel/').last : null;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        width: orientation == .landscape ? 96 : double.infinity,
        height: orientation == .portrait ? 96 : double.infinity,
        child: ListView(
          scrollDirection: orientation == .portrait ? Axis.horizontal : Axis.vertical,

          children: channelButtons(context, active),
        ),
      ),
    );
  }

  static List<IconButton> channelButtons(BuildContext context, String? active) {
    final channels = Channels.all;
    return channels
        .map(
          (c) => IconButton(
            padding: .symmetric(horizontal: 3),
            onPressed: () => context.pushReplacement('/channel/${c.id}'),
            icon: desaturate(c, active == null || active == c.id),
          ),
        )
        .toList();
  }

  static Widget desaturate(Channel channel, bool active) {
    return active
        ? channel.icon
        : ColorFiltered(
            colorFilter: ColorFilter.matrix([
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
            child: channel.icon,
          );
  }
}
