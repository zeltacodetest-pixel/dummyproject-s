import 'package:flutter/material.dart';

import '../services/app_dependencies.dart';
import '../services/offline_data_store.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OfflineDataStore store = AppDependencies.of(context).offlineDataStore;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Profile & privacy',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Manage your local data. Everything stays on this device unless you choose to export it.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: store.isInitialized
                  ? () async {
                      await store.clearSessions();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Local data cleared.')),
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete local sessions'),
            ),
          ],
        ),
      ),
    );
  }
}
