import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_alarm_app/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const TravelAlarmApp(isOnboardingComplete: false),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
