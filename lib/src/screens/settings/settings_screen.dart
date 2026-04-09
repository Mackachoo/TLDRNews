import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/app_scaffold.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: ListView(
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          themeModeTile(),
          Text('Notifications', style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
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
