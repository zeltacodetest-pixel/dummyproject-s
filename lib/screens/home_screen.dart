import 'package:flutter/material.dart';

import '../navigation/app_navigation.dart';
import '../services/app_dependencies.dart';
import '../services/legal_content_service.dart';
import '../services/offline_data_store.dart';
import '../widgets/legal_document_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _tips = <String>[
    'Stand near a window or soft light to avoid harsh shadows.',
    'Clean your camera lens for clearer images of your scalp.',
    'Frame the guides so the top, side, and back views fill the screen.',
    'Ask a friend for help capturing the back view if possible.',
  ];

  int _tipIndex = 0;

  void _cycleTip() {
    setState(() {
      _tipIndex = (_tipIndex + 1) % _tips.length;
    });
  }

  Future<void> _showPrivacySheet(BuildContext context) async {
    final LegalContentService legalService =
        AppDependencies.of(context).legalContentService;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => LegalDocumentSheet(
        title: 'Privacy Policy',
        loader: () => legalService.fetchDocument(LegalDocumentType.privacy),
      ),
    );
  }

  Future<void> _showHowItWorksSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Text(
                'How HairGuard works',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              _HowItWorksStep(
                icon: Icons.filter_3,
                text: 'Follow the guided prep checklist to get ready.',
              ),
              _HowItWorksStep(
                icon: Icons.camera_alt_outlined,
                text: 'Capture top, side, and back views with on-screen guidance.',
              ),
              _HowItWorksStep(
                icon: Icons.insights_outlined,
                text: 'Processing runs on your phone to surface friendly insights.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final OfflineDataStore store = AppDependencies.of(context).offlineDataStore;

    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, _) {
        if (!store.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        final ThemeData theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Welcome to HairGuard',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Keep an eye on your scalp with guided captures. Everything stays on this device by default.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.tips_and_updates_outlined, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Capture tip', style: theme.textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(_tips[_tipIndex], style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _cycleTip,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Show another tip',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => _showHowItWorksSheet(context),
                      child: const Text('How it works'),
                    ),
                    TextButton(
                      onPressed: () => _showPrivacySheet(context),
                      child: const Text('Privacy'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => DefaultTabNavigator.of(context)?.goTo(AppTab.scan),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Start a new scan'),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: store.sessions.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.camera_enhance_outlined, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          const Text('No scans yet — start your first scan to build your history.'),
        ],
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  const _HowItWorksStep({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
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
