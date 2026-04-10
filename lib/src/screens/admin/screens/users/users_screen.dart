import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/screens/admin/screens/users/users_controller.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctlr = AdminUsersController();
    return Container(
      color: context.colors.surface,
      padding: .all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: .min,
        children: [
          Text('Admins', style: Theme.of(context).textTheme.headlineMedium),
          ListenableBuilder(
            listenable: ctlr,
            builder: (context, child) {
              if (ctlr.loading) return const Center(child: CircularProgressIndicator());
              if (ctlr.admins == null) return const Center(child: Text('Failed to load users'));

              return Expanded(
                child: ListView.builder(
                  itemCount: ctlr.admins!.length,
                  itemBuilder: (context, index) {
                    final admin = ctlr.admins![index];
                    return ListTile(
                      title: Text(admin?.name ?? 'Unnamed'),
                      subtitle: Text(admin?.uid ?? 'No UID'),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
