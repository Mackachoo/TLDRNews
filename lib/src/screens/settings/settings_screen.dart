import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: App.ctlr.settings,
      builder: (context, child) {
        return Container(
          color: context.colors.surface,
          child: ListView(
            padding: .all(16),
            children: [
              Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 8),
              themeModeTile(),
              SizedBox(height: 16),
              Text('Notifications', style: Theme.of(context).textTheme.headlineSmall),
              allNotificationsTile(),
            ],
          ),
        );
      },
    );
  }

  SwitchListTile allNotificationsTile() {
    return SwitchListTile(
      title: Text('Enable Notifications'),
      value: App.ctlr.settings.notifications.all,
      onChanged: (value) => App.ctlr.settings.notifications.all = value,
    );
  }

  ListTile themeModeTile() {
    return ListTile(
      title: Text('Appearance Theme'),
      trailing: MenuAnchor(
        menuChildren: [
          MenuItemButton(
            onPressed: () => App.ctlr.settings.appearance.theme = ThemeMode.system,
            child: Text('System'),
          ),
          MenuItemButton(
            onPressed: () => App.ctlr.settings.appearance.theme = ThemeMode.light,
            child: Text('Light'),
          ),
          MenuItemButton(
            onPressed: () => App.ctlr.settings.appearance.theme = ThemeMode.dark,
            child: SizedBox(width: 96, child: Text('Dark')),
          ),
        ],
        builder: (context, controller, child) {
          return SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: Row(
                mainAxisSize: .max,
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(App.ctlr.settings.appearance.theme.toString().split('.').last.capitalize()),
                  PhosphorIcon(PhosphorIcons.caretDown()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
