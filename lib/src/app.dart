import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tldrnews_app/src/app_controller.dart';
import 'package:tldrnews_app/src/app_shell.dart';
import 'package:tldrnews_app/src/screens/admin/screens/channel/channel_screen.dart';
import 'package:tldrnews_app/src/screens/admin/screens/users/users_screen.dart';
import 'package:tldrnews_app/src/screens/auth/auth_screen.dart';
import 'package:tldrnews_app/src/screens/admin/admin_screen.dart';
import 'package:tldrnews_app/src/screens/channels/channel_screen.dart';
import 'package:tldrnews_app/src/screens/error/error_screen.dart';
import 'package:tldrnews_app/src/screens/home/home_screen.dart';
import 'package:tldrnews_app/src/screens/settings/settings_screen.dart';
import 'package:tldrnews_app/src/screens/video/video_screen.dart';
import 'package:tldrnews_app/src/utils/theme.dart';

class App extends StatelessWidget {
  static final ctlr = AppCtlr();

  late final GoRouter appRouter;
  App({super.key}) {
    appRouter = router();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ctlr.settings, ctlr.auth]),
      builder: (context, child) {
        return MaterialApp.router(
          restorationScopeId: 'app',
          routerConfig: appRouter,

          theme: TLDRTheme.light,
          darkTheme: TLDRTheme.dark,
          themeMode: ctlr.settings.appearance.theme,
        );
      },
    );
  }

  static GoRouter router() {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        if (state.uri.path.startsWith('/admin') && ctlr.auth.meta?.admin != true) return '/';
        return null;
      },
      errorBuilder: (context, state) => ErrorScreen(state.error),
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(state: state, child: child),
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
            GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
            GoRoute(path: '/account', builder: (context, state) => const AuthScreen()),
            GoRoute(
              path: '/channel/:id',
              builder: (context, state) => ChannelScreen(cid: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/video/:id',
              builder: (context, state) => VideoScreen(state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/admin',
              builder: (context, state) => const AdminScreen(),
              routes: [
                GoRoute(path: 'users', builder: (context, state) => const AdminUsersScreen()),
                GoRoute(
                  path: '/channel/:id',
                  builder: (context, state) => AdminChannelScreen(cid: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
