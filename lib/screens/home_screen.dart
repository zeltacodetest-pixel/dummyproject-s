import 'package:flutter/material.dart';

import '../navigation/app_navigation.dart';
import '../services/app_dependencies.dart';
import '../services/offline_data_store.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OfflineDataStore store = AppDependencies.of(context).offlineDataStore;

    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, _) {
        if (!store.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Welcome to HairGuard',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Good lighting, a steady hand, and framing each angle will help you get accurate insights.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => DefaultTabNavigator.of(context)?.goTo(AppTab.scan),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Start a new scan'),
                ),
                const SizedBox(height: 24),
                if (store.sessions.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No scans yet — capture your first session to unlock results.'),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: store.sessions.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (BuildContext context, int index) {
                        final ScanSession session = store.sessions[index];
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(session.summary ?? 'Session ${session.id}'),
                          subtitle: Text('Captured on ${session.createdAt.toLocal()}'),
                        );
                      },
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

class DefaultTabNavigator extends InheritedWidget {
  const DefaultTabNavigator({
    super.key,
    required super.child,
    required this.goTo,
  });

  final void Function(AppTab tab) goTo;

  static DefaultTabNavigator? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DefaultTabNavigator>();
  }

  @override
  bool updateShouldNotify(DefaultTabNavigator oldWidget) => goTo != oldWidget.goTo;
}
