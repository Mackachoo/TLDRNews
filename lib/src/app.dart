import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tldrnews_app/src/app_controller.dart';
import 'package:tldrnews_app/src/app_shell.dart';
import 'package:tldrnews_app/src/screens/home/home_screen.dart';
import 'package:tldrnews_app/src/screens/settings/settings_screen.dart';
import 'package:tldrnews_app/src/utils/theme.dart';

class TLDRNewsApp extends StatelessWidget {
  static final ctlr = AppCtlr();

  late final GoRouter appRouter;
  TLDRNewsApp({super.key}) {
    appRouter = router();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      restorationScopeId: 'app',
      routerConfig: appRouter,

      theme: TLDRTheme.light,
      darkTheme: TLDRTheme.dark,
      themeMode: ctlr.settings.appearance.theme,
    );
  }

  static GoRouter router() {
    return GoRouter(
      initialLocation: '/',
      // errorBuilder: (context, state) =>
      //     ErrorScreen(context.locale.error_pageNotFound, errorDesc: state.error.toString()),
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
            GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
          ],
        ),
      ],
    );
  }
}
