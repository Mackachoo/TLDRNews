import 'package:material_ui/material_ui.dart';
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

  static Page<void> page(GoRouterState state, Widget child) =>
      NoTransitionPage(key: state.pageKey, child: child);

  static GoRouter router() {
    GoRouter.optionURLReflectsImperativeAPIs = true;
    return GoRouter(
      initialLocation: '/',
      // debugLogDiagnostics: true,
      refreshListenable: ctlr.auth,
      redirect: (context, state) {
        if (state.uri.path.startsWith('/admin')) {
          if (!ctlr.auth.resolved) return '/';
          if (ctlr.auth.meta?.admin != true) return '/';
        } else if (state.uri.path.contains('party')) {
          if (!ctlr.auth.resolved) return '/';
          if (ctlr.auth.meta?.partyApproved != true) return '/';
        }
        return null;
      },
      errorBuilder: (context, state) => ErrorScreen(state.error),
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              pageBuilder: (context, state) => page(state, const HomeScreen()),
              routes: [
                GoRoute(
                  path: 'settings',
                  name: 'settings',
                  pageBuilder: (context, state) => page(state, const SettingsScreen()),
                ),
                GoRoute(
                  path: 'account',
                  name: 'account',
                  pageBuilder: (context, state) => page(state, const AuthScreen()),
                ),
                GoRoute(
                  path: 'channel/:id',
                  name: 'channel',
                  pageBuilder: (context, state) => page(
                    state,
                    // pageKey is per-GoRoute, not per-param, so key on the id to
                    // rebuild state when switching between channels.
                    ChannelScreen(
                      key: ValueKey(state.pathParameters['id']),
                      cid: state.pathParameters['id']!,
                    ),
                  ),
                ),
                GoRoute(
                  path: 'video/:id',
                  name: 'video',
                  pageBuilder: (context, state) => page(
                    state,
                    VideoScreen(
                      state.pathParameters['id']!,
                      key: ValueKey(state.pathParameters['id']),
                    ),
                  ),
                ),
                GoRoute(
                  path: 'admin',
                  name: 'admin',
                  pageBuilder: (context, state) => page(state, const AdminScreen()),
                  routes: [
                    GoRoute(
                      path: 'users',
                      name: 'admin-users',
                      pageBuilder: (context, state) => page(state, const AdminUsersScreen()),
                    ),
                    GoRoute(
                      path: 'channel/:id',
                      name: 'admin-channel',
                      pageBuilder: (context, state) => page(
                        state,
                        AdminChannelScreen(
                          key: ValueKey(state.pathParameters['id']),
                          cid: state.pathParameters['id']!,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
