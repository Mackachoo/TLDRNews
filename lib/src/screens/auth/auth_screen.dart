import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
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
                          leading: PhosphorIcon(
                            PhosphorIcons.shieldStar(PhosphorIconsStyle.bold),
                            color: context.colors.tertiary,
                          ),
                          title: Text('You are a TLDR Admin'),
                        ),
                      if (App.ctlr.auth.meta?.party == true)
                        ListTile(
                          leading: Image.asset('assets/logos/tldr-party.png', height: 32),
                          title: Text('You are a TLDR Party Member!'),
                        ),
                    ]
                  : [],
              SizedBox(height: 32),
              ElevatedButton(onPressed: App.ctlr.auth.signOut, child: Text('Sign Out')),
            ],
          ),
        );
      },
    );
  }

  Widget login() {
    return Builder(
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
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
                  backgroundColor: WidgetStateProperty.all(context.colors.tertiary),
                ),
                onPressed: null,
                // onPressed: () => App.ctlr.account.signInWithApple(context),
                icon: Image.asset('assets/auth/apple.png', height: 24),
                label: Text(
                  '  Sign in with Apple       ',
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: context.colors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ButtonStyle get loginButtonTheme => ElevatedButton.styleFrom(padding: .all(24));
}
