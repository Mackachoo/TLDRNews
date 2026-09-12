import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) => Container(
    color: context.colors.surface,
    child: ListenableBuilder(
      listenable: App.ctlr.auth,
      builder: (context, child) {
        return App.ctlr.auth.user != null ? account() : login();
      },
    ),
  );

  Widget account() {
    return Builder(
      builder: (context) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: .all(16),
              children: [
                ...App.ctlr.auth.account != null
                    ? [
                        ListTile(
                          title: Text(
                            'Hi, ${App.ctlr.auth.user!.displayName}',
                            style: context.textTheme.headlineMedium,
                          ),
                        ),
                        ListTile(
                          title: Text('Email:', style: context.textTheme.titleMedium),
                          trailing: Card(
                            child: Padding(
                              padding: .all(8.0),
                              child: Text(
                                App.ctlr.auth.account!.email ?? 'No email',
                                style: context.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ),
                        if (App.ctlr.auth.meta?.admin == true)
                          ListTile(
                            leading: Icon(
                              Icons.admin_panel_settings,
                              color: context.colors.tertiary,
                            ),
                            title: Text('You are a TLDR Admin'),
                          ),
                        if (App.ctlr.auth.meta?.partyApproved == true)
                          ListTile(
                            leading: Image.asset('assets/logos/tldr-party.png', height: 32),
                            title: Text('You are a TLDR Party Member!'),
                          ),
                        if (App.ctlr.auth.meta?.partyApproved == false)
                          ListTile(
                            leading: Image.asset('assets/logos/tldr-party.png', height: 32),
                            title: Text('Get your TLDR Party Membership approved!'),
                            trailing: Icon(Icons.approval),
                            onTap: () => partyApprovalDialog(context),
                          ),
                      ]
                    : [],
                SizedBox(height: 32),
                ElevatedButton(onPressed: App.ctlr.auth.signOut, child: Text('Sign Out')),
              ],
            ),
          ),
        );
      },
    );
  }

  // Picks a random video from TLDR Party from the last 14 days, then requests the URL for the video. If it matches the videoId,
  //the user becomes a TLDR Party member. Instead of this being a bool it is now a date. It is valid as long as the user Party
  //membership date is with 90 days.
  Future<void> partyApprovalDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Party Membership Approval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'To validate your TLDR Party membership, you need to fetch the URL for the following video from TLDR Party blog. If the URL matches the video ID, your membership will be approved for 90 days.',
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          // ElevatedButton(
          //   onPressed: () => Navigator.pop(context, true),
          //   child: const Text('Rebuild'),
          // ),
        ],
      ),
    );
    // if (confirmed == true && mounted) {
    //   await ctlr.fetchChannelContentFromYoutube(context, rebuild: true);
    // }
  }

  Widget login() {
    return Builder(
      builder: (context) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: .all(16),
              children: [
                ElevatedButton.icon(
                  style: loginButtonTheme,
                  onPressed: () => App.ctlr.auth.signInWithGoogle(context),
                  icon: Image.asset('assets/auth/google.png', height: 24),
                  label: Text(
                    '  Sign in with Google   ',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: context.colors.onPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  style: loginButtonTheme.copyWith(
                    backgroundColor: WidgetStateProperty.all(
                      context.colors.surfaceContainerHighest,
                    ),
                  ),
                  onPressed: null,
                  // onPressed: () => App.ctlr.account.signInWithApple(context),
                  icon: Image.asset('assets/auth/apple.png', height: 24),
                  label: Text(
                    '  Sign in with Apple       ',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ButtonStyle get loginButtonTheme => ElevatedButton.styleFrom(padding: .all(24));
}
