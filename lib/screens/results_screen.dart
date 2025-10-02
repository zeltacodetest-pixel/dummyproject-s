import 'package:flutter/material.dart';

import '../services/app_dependencies.dart';
import '../services/offline_data_store.dart';
import '../services/processing_service.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OfflineDataStore store = AppDependencies.of(context).offlineDataStore;
    final ProcessingService processingService =
        AppDependencies.of(context).processingService;

    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, _) {
        if (!store.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        final ScanSession? latestSession =
            store.sessions.isNotEmpty ? store.sessions.first : null;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Results overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Stored locally: ${store.sessions.length} session(s).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  latestSession == null
                      ? 'No processed sessions yet. Complete a scan to see your results summary here.'
                      : latestSession.summary ?? 'Latest session ready to review.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (latestSession != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Model version: ${processingService.modelVersion}'),
                          const SizedBox(height: 8),
                          Text('Captured: ${latestSession.createdAt.toLocal()}'),
                        ],
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
}
