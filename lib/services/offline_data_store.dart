import 'dart:collection';

import 'package:flutter/foundation.dart';

class ScanSession {
  ScanSession({
    required this.id,
    required this.createdAt,
    this.summary,
  });

  final String id;
  final DateTime createdAt;
  final String? summary;
}

enum AccountPreference { unknown, signedIn, skipped }

class OfflineDataStore extends ChangeNotifier {
  bool _initialized = false;
  final List<ScanSession> _sessions = <ScanSession>[];
  bool _onboardingComplete = false;
  AccountPreference _accountPreference = AccountPreference.unknown;
  String? _linkedAccountId;

  bool get isInitialized => _initialized;

  bool get hasCompletedOnboarding => _onboardingComplete;

  bool get hasLinkedAccount => _accountPreference == AccountPreference.signedIn;

  bool get shouldPromptForAccount =>
      _accountPreference == AccountPreference.unknown;

  String? get linkedAccountId => _linkedAccountId;

  UnmodifiableListView<ScanSession> get sessions =>
      UnmodifiableListView<ScanSession>(_sessions);

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _initialized = true;
    notifyListeners();
  }

  Future<void> saveSession(ScanSession session) async {
    await initialize();
    _sessions.insert(0, session);
    notifyListeners();
  }

  Future<void> clearSessions() async {
    await initialize();
    _sessions.clear();
    notifyListeners();
  }

  Future<void> setOnboardingComplete() async {
    await initialize();
    if (_onboardingComplete) {
      return;
    }
    _onboardingComplete = true;
    notifyListeners();
  }

  Future<void> linkAccount(String accountId) async {
    await initialize();
    _linkedAccountId = accountId;
    _accountPreference = AccountPreference.signedIn;
    notifyListeners();
  }

  Future<void> skipAccount() async {
    await initialize();
    _linkedAccountId = null;
    _accountPreference = AccountPreference.skipped;
    notifyListeners();
  }
}
