import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

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

    bool showReturn = route != '/' && !route.startsWith('/channel/');

    return AppBar(
      backgroundColor: context.colors.secondaryFixedDim,
      foregroundColor: context.colors.onSecondaryFixed,
      leadingWidth: 96,
      leading: SizedBox(
        height: double.infinity,
        child: AspectRatio(
          aspectRatio: 1,
          child: IconButton(
            padding: .symmetric(horizontal: 8, vertical: 0),
            onPressed: () => showReturn ? context.forcePop() : context.go('/'),
            icon: showReturn && !kIsWeb
                ? PhosphorIcon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold))
                : Image.asset('assets/logos/tldr-white.png', height: double.infinity),
          ),
        ),
      ),
      title: Text(title),
      actionsPadding: .zero,
      actions: actions.entries
          .map((entry) => actionButton(context, destination: entry.key, icon: entry.value))
          .toList(),
    );
  }

  static Map<String, PhosphorIconData> get actions => {
    if (App.ctlr.auth.meta?.admin == true)
      '/admin': PhosphorIcons.shieldStar(PhosphorIconsStyle.bold),
    '/account': PhosphorIcons.userCircle(PhosphorIconsStyle.bold),
    '/settings': PhosphorIcons.gear(PhosphorIconsStyle.bold),
  };

  static SizedBox actionButton(
    BuildContext context, {
    required String destination,
    required PhosphorIconData icon,
  }) {
    final route = GoRouterState.of(context).uri.toString();

    return SizedBox(
      height: double.infinity,
      child: AspectRatio(
        aspectRatio: 1,
        child: IconButton(
          padding: .zero,
          onPressed: () => route == destination ? null : context.go(destination),
          icon: PhosphorIcon(icon),
        ),
      ),
    );
  }

  static Widget navbar(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final route = context.uri.toString();
    bool admin = route.startsWith('/admin');
    if (route == '/') return SizedBox.shrink();
    final channels = App.ctlr.auth.meta?.channels ?? ChannelSnippets.free;
    final buttons = channels
        .map(
          (c) => c.button(
            context,
            desaturate: true,
            onTap: (id) => context.go('/${admin ? 'admin/channel' : 'channel'}/$id'),
          ),
        )
        .toList();

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
            itemCount: buttons.length,
            itemBuilder: (context, index) => buttons[index],
          ),
        ),
      ),
    );
  }
}
