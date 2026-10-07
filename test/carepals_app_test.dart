import 'package:carepals/app/carepals_app.dart';
import 'package:carepals/core/database/app_database.dart';
import 'package:carepals/core/models/user_profile.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _testProfile = UserProfile(fullName: 'Alex Miller', role: 'Lead Caregiver');
DateTime _now = DateTime(2025, 9, 14, 10);
DateTime _clock() => _now;

Future<void> _loadFonts() async {
  final loader = FontLoader('PlusJakartaSans');
  for (final f in Directory('assets/fonts').listSync().whereType<File>()) {
    loader.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
  }
  await loader.load();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    CarePalsApp(appDatabase: AppDatabase.inMemory(), initialProfile: _testProfile, clock: _clock),
  );
  await tester.pumpAndSettle();
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  setUpAll(_loadFonts);

  testWidgets('shell exposes four navigation destinations', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Physical'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('home dashboard is personalised and dated', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Alex Miller'), findsWidgets);
    expect(find.text('Sep 14, 2025'), findsOneWidget);
    expect(find.text('Hello Alex! How are you feeling today?'), findsOneWidget);
    expect(find.text('Current Session'), findsOneWidget);
  });

  testWidgets('session timer starts and pauses', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Start'), findsOneWidget);
    await _tapVisible(tester, find.text('Start'));
    await tester.pump();
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Active Caregiving'), findsOneWidget);

    _now = _now.add(const Duration(hours: 2, minutes: 15));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('2h 15m'), findsOneWidget);

    await _tapVisible(tester, find.text('Pause'));
    await tester.pump();
    expect(find.text('Resume'), findsOneWidget);
  });

  testWidgets('quiz advances through questions', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Question 1/8'), findsOneWidget);
    await _tapVisible(tester, find.text('Yes'));
    await tester.pumpAndSettle();
    expect(find.text('Question 2/8'), findsOneWidget);
  });

  testWidgets('mood calendar shows the real month and navigates', (tester) async {
    await _pumpApp(tester);

    final label = find.byKey(const Key('calendar-month-label'));
    await tester.ensureVisible(label);
    expect(find.text('September 2025'), findsOneWidget);

    await _tapVisible(tester, find.bySemanticsLabel('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('August 2025'), findsOneWidget);
  });

  testWidgets('editing the profile updates the name everywhere', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Account Details'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Alex Miller'), 'Sarah Jenkins');
    await _tapVisible(tester, find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Sarah Jenkins'), findsWidgets);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Hello Sarah! How are you feeling today?'), findsOneWidget);
  });

  testWidgets('physical support filters by category and search', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Physical'));
    await tester.pumpAndSettle();
    expect(find.text('In-home Care Services'), findsOneWidget);

    await _tapVisible(tester, find.text('Therapy'));
    await tester.pumpAndSettle();
    expect(find.text('Physical Therapy'), findsOneWidget);
    expect(find.text('In-home Care Services'), findsNothing);

    await _tapVisible(tester, find.text('All Services'));
    await tester.enterText(find.byType(TextField), 'respite');
    await tester.pumpAndSettle();
    expect(find.text('Respite Centers'), findsOneWidget);
    expect(find.text('Physical Therapy'), findsNothing);
  });
}
