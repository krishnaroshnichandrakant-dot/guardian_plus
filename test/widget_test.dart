import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardian_plus/main.dart';

void main() {
  testWidgets('Guardian Plus App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GuardianPlusApp(),
      ),
    );
    // Logo icon should be present
    expect(find.byIcon(Icons.shield_rounded), findsAtLeastNWidgets(1));
    // Settle pending 2.5s timer in SplashScreen
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
