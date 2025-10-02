import 'package:flutter/material.dart';

import 'navigation/app_navigation.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/results_screen.dart';
import 'screens/scan_screen.dart';
import 'services/app_dependencies.dart';
import 'services/offline_data_store.dart';
import 'services/permission_service.dart';
import 'services/processing_service.dart';

void main() {
  runApp(const HairGuardApp());
}

class HairGuardApp extends StatefulWidget {
  const HairGuardApp({super.key});

  @override
  State<HairGuardApp> createState() => _HairGuardAppState();
}

class _HairGuardAppState extends State<HairGuardApp> {
  late final OfflineDataStore _offlineDataStore;
  late final PermissionService _permissionService;
  late final ProcessingService _processingService;
  int _currentIndex = AppTab.home.index;

  @override
  void initState() {
    super.initState();
    _offlineDataStore = OfflineDataStore()..initialize();
    _permissionService = PermissionService();
    _processingService = ProcessingService();
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) {
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppDependencies(
      offlineDataStore: _offlineDataStore,
      permissionService: _permissionService,
      processingService: _processingService,
      child: MaterialApp(
        title: 'HairGuard',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: AppShell(
          currentIndex: _currentIndex,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  Widget _buildBody() {
    switch (AppTab.values[currentIndex]) {
      case AppTab.home:
        return const HomeScreen();
      case AppTab.scan:
        return const ScanScreen();
      case AppTab.results:
        return const ResultsScreen();
      case AppTab.profile:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = _buildBody();
    return DefaultTabNavigator(
      goTo: (AppTab tab) => onTabSelected(tab.index),
      child: Scaffold(
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTabSelected,
          items: AppTab.values
              .map(
                (tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  label: tab.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
