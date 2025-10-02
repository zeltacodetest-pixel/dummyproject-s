import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skalp_guard/main.dart';
import 'package:skalp_guard/navigation/app_navigation.dart';

void main() {
  testWidgets('Bottom navigation renders four HairGuard tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const HairGuardApp());

    final BottomNavigationBar bottomNav =
        tester.widget(find.byType(BottomNavigationBar));

    expect(bottomNav.items, hasLength(AppTab.values.length));
    for (final AppTab tab in AppTab.values) {
      expect(find.text(tab.label), findsWidgets);
    }
  });
}
