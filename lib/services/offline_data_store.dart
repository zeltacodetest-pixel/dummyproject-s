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

class OfflineDataStore extends ChangeNotifier {
  bool _initialized = false;
  final List<ScanSession> _sessions = <ScanSession>[];

  bool get isInitialized => _initialized;

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
}
