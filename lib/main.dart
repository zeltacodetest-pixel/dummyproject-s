import 'package:flutter/material.dart';

import 'navigation/app_navigation.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/results_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/sign_in_screen.dart';
import 'services/app_dependencies.dart';
import 'services/account_service.dart';
import 'services/analytics_service.dart';
import 'services/legal_content_service.dart';
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
  late final AccountService _accountService;
  late final AnalyticsService _analyticsService;
  late final LegalContentService _legalContentService;
  int _currentIndex = AppTab.home.index;

  @override
  void initState() {
    super.initState();
    _offlineDataStore = OfflineDataStore()..initialize();
    _permissionService = PermissionService();
    _processingService = ProcessingService();
    _accountService = AccountService();
    _analyticsService = AnalyticsService();
    _legalContentService = LegalContentService();
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
      accountService: _accountService,
      analyticsService: _analyticsService,
      legalContentService: _legalContentService,
      child: AnimatedBuilder(
        animation: _offlineDataStore,
        builder: (BuildContext context, _) {
          return MaterialApp(
            title: 'HairGuard',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            ),
            home: _buildRoot(context),
          );
        },
      ),
    );
  }

  Widget _buildRoot(BuildContext context) {
    if (!_offlineDataStore.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_offlineDataStore.hasCompletedOnboarding) {
      return OnboardingScreen(
        onContinue: () => _offlineDataStore.setOnboardingComplete(),
      );
    }

    if (_offlineDataStore.shouldPromptForAccount) {
      return SignInScreen(
        onAccountLinked: (String accountId) async {
          await _offlineDataStore.linkAccount(accountId);
        },
        onSkip: () async {
          _analyticsService.recordEvent('account_skip');
          await _offlineDataStore.skipAccount();
        },
      );
    }

    return AppShell(
      currentIndex: _currentIndex,
      onTabSelected: _onTabSelected,
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
