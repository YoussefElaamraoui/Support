import 'package:carepals/app/carepals_app.dart';
import 'package:carepals/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shell exposes four navigation destinations', (tester) async {
    await tester.pumpWidget(CarePalsApp(appDatabase: AppDatabase.inMemory()));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Physical'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('home dashboard content is visible by default', (tester) async {
    await tester.pumpWidget(CarePalsApp(appDatabase: AppDatabase.inMemory()));

    expect(find.text('Welcome back, Alex Miller'), findsOneWidget);
    expect(find.text('2h 15m Active Caregiving'), findsOneWidget);
    expect(find.text('Mood Calendar'), findsOneWidget);
  });
}
