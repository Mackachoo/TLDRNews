import 'package:material_ui/material_ui.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/services/functions_service.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';
import 'package:tldrnews_app/src/utils/message.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) => Material(
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
                        if (App.ctlr.auth.meta?.partyState == .member)
                          ListTile(
                            leading: Image.asset('assets/logos/tldr-party.png', height: 32),
                            title: Text('You are a TLDR Party Member!'),
                          ),
                        if (App.ctlr.auth.meta?.partyState != .member)
                          ListTile(
                            leading: Image.asset('assets/logos/tldr-party.png', height: 32),
                            title: Text('Get your TLDR Party Membership approved!'),
                            subtitle: Text('You\'re membership has expired, please refresh.'),
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
      builder: (context) => FutureBuilder(
        future: FunctionsService.requestVideoForApproval(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState != .done) {
            return Center(child: CircularProgressIndicator());
          }

          final videoTitle = asyncSnapshot.data?['title'];
          final videoPublished = asyncSnapshot.data?['published'];
          ValueNotifier<int?> guesses = ValueNotifier<int?>(asyncSnapshot.data?['guesses']);

          final videoHash = asyncSnapshot.data?['hash'];

          if (asyncSnapshot.hasError ||
              videoTitle == null ||
              videoPublished == null ||
              videoHash == null ||
              guesses.value == null) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('An error occurred while fetching the video: ${asyncSnapshot.error}'),
            );
          }
          final published = DateTime.tryParse(videoPublished)?.toLocal();
          final controller = TextEditingController();

          return AlertDialog(
            title: const Text('Party Membership Approval'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'To validate your TLDR Party membership, you need to fetch the URL for the following video from TLDR Party blog. If the URL matches the video ID, your membership will be approved for 90 days.',
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: .all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(videoTitle, style: context.textTheme.headlineSmall),
                        SizedBox(height: 16),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            published?.toUI() ?? videoPublished,
                            style: context.textTheme.labelMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                ValueListenableBuilder(
                  valueListenable: guesses,
                  builder: (context, value, child) {
                    return Text(
                      '${guesses.value} tries for this video',
                      style: context.textTheme.bodySmall?.copyWith(color: context.colors.error),
                    );
                  },
                ),
              ],
            ),
            actions: [
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Enter Video URL',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (url) => _submitPartyVideo(context, url, videoHash, guesses),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        _submitPartyVideo(context, controller.text, videoHash, guesses),
                    child: const Text('Submit'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _submitPartyVideo(
    BuildContext context,
    String url,
    String videoHash,
    ValueNotifier<int?> guesses,
  ) async {
    guesses.value = (guesses.value ?? 0) - 1;
    if (guesses.value! <= 0) {
      if (context.mounted) {
        Message.error(context, 'Too many failed attempts. Please try again later.');
        Navigator.pop(context, false);
      }
      return;
    }

    final result = await FunctionsService.approvePartyVideo(url, videoHash);
    if (result?['approved'] == true) {
      if (context.mounted) {
        Message.success(context, 'Your TLDR Party membership has been approved!');
        await App.ctlr.auth.refresh();
        if (context.mounted) Navigator.pop(context, true);
      }
    } else {
      if (context.mounted) {
        Message.error(context, 'Incorrect video URL. Please try again.');
      }
    }
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
