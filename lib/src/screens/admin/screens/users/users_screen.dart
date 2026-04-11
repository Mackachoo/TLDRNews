import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
        spacing: 16,
        children: [
          Text('Admins', style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => addAdminPopup(context, ctlr),
              child: const Text('Add Admin'),
            ),
          ),
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
                      trailing: IconButton(
                        icon: PhosphorIcon(PhosphorIcons.x()),
                        onPressed: () => ctlr.removeAdmin(context, admin!.uid),
                      ),
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

  void addAdminPopup(BuildContext context, AdminUsersController ctlr) {
    final uidCtlr = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Admin'),
        content: TextField(
          controller: uidCtlr,
          decoration: const InputDecoration(labelText: 'User Email...'),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => context.pop(uidCtlr.text), child: const Text('Add')),
        ],
      ),
    ).then((email) {
      // ignore: use_build_context_synchronously
      if (email != null && email is String && email.isNotEmpty) ctlr.addAdmin(context, email);
    });
  }
}
