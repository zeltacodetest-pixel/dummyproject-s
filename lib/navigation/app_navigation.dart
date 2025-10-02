import 'package:flutter/material.dart';

enum AppTab { home, scan, results, profile }

extension AppTabMetadata on AppTab {
  String get label {
    switch (this) {
      case AppTab.home:
        return 'Home';
      case AppTab.scan:
        return 'Scan';
      case AppTab.results:
        return 'Results';
      case AppTab.profile:
        return 'Profile';
    }
  }

  IconData get icon {
    switch (this) {
      case AppTab.home:
        return Icons.home_outlined;
      case AppTab.scan:
        return Icons.camera_alt_outlined;
      case AppTab.results:
        return Icons.analytics_outlined;
      case AppTab.profile:
        return Icons.person_outline;
    }
  }
}

extension AppTabParsing on AppTab {
  static AppTab fromIndex(int index) {
    if (index < 0 || index >= AppTab.values.length) {
      return AppTab.home;
    }
    return AppTab.values[index];
  }
}
