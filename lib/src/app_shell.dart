import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

/// Chrome shared by every route: app bar, channel navbar and a content column
/// capped at 800px. The navbar sits at the bottom in portrait and the side in
/// landscape, and is hidden on the home route.
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

  /// App bar titled with the current channel (and "(Admin)" under `/admin`),
  /// with a back button whenever the route is not the root.
  static AppBar appBar(BuildContext context) {
    final route = GoRouterState.of(context).uri.toString();
    final title =
        '${route.contains('/channel/') ? ChannelSnippets.byId(route.split('/channel/').last)?.name ?? 'TLDR News' : 'TLDR News'}${route.startsWith('/admin') ? ' (Admin)' : ''}';

    final canGoBack = GoRouterState.of(context).uri.path != '/';

    return AppBar(
      backgroundColor: context.colors.secondaryFixedDim,
      foregroundColor: context.colors.onSecondaryFixed,
      automaticallyImplyLeading: false,
      leadingWidth: canGoBack ? 120 : 60,
      titleSpacing: 0,
      leading: Row(
        mainAxisSize: .min,
        children: [
          if (canGoBack)
            IconButton(
              padding: .symmetric(horizontal: 8, vertical: 0),
              onPressed: () => context.forcePop(),
              icon: const Icon(Icons.arrow_back),
            ),
          SizedBox(
            height: double.infinity,
            child: AspectRatio(
              aspectRatio: 1,
              child: IconButton(
                padding: .symmetric(horizontal: 8, vertical: 0),
                // The logo resets to the root rather than stacking another home.
                onPressed: () => context.go('/'),
                icon: Image.asset('assets/logos/tldr-white.png', height: double.infinity),
              ),
            ),
          ),
        ],
      ),
      title: Text(title),
      actionsPadding: .zero,
      actions: actions.entries
          .map((entry) => actionButton(context, destination: entry.key, icon: entry.value))
          .toList(),
    );
  }

  /// App bar destinations. The admin entry only appears for admins.
  static Map<String, IconData> get actions => {
    if (App.ctlr.auth.meta?.admin == true) '/admin': Icons.admin_panel_settings,
    '/account': Icons.account_circle,
    '/settings': Icons.settings,
  };

  /// Square app bar button that pushes [destination], or does nothing if the
  /// user is already there.
  static SizedBox actionButton(
    BuildContext context, {
    required String destination,
    required IconData icon,
  }) {
    final route = GoRouterState.of(context).uri.toString();

    return SizedBox(
      height: double.infinity,
      child: AspectRatio(
        aspectRatio: 1,
        child: IconButton(
          padding: .zero,
          onPressed: () => route == destination ? null : context.push(destination),
          icon: Icon(icon),
        ),
      ),
    );
  }

  /// Channel buttons for the channels the user can see. Taps navigate to the
  /// admin editor for that channel when inside `/admin`, else to the public one.
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
            desaturate: false,
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
