import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skalp_guard/main.dart';
import 'package:skalp_guard/navigation/app_navigation.dart';

void main() {
  testWidgets('Onboarding requires consent before entering the app shell',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HairGuardApp());

    await tester.pump();

    expect(find.text('Welcome to HairGuard'), findsOneWidget);

    final Finder consentCheckbox = find.byType(CheckboxListTile);
    expect(consentCheckbox, findsOneWidget);

    ElevatedButton continueButton =
        tester.widget(find.widgetWithText(ElevatedButton, 'Continue'));
    expect(continueButton.onPressed, isNull);

    await tester.tap(consentCheckbox);
    await tester.pumpAndSettle();

    continueButton =
        tester.widget(find.widgetWithText(ElevatedButton, 'Continue'));
    expect(continueButton.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Sync your scans'), findsOneWidget);

    await tester.tap(find.text('Continue without account'));
    await tester.pumpAndSettle();

    final BottomNavigationBar bottomNav =
        tester.widget(find.byType(BottomNavigationBar));

    expect(bottomNav.items, hasLength(AppTab.values.length));
  });
}
