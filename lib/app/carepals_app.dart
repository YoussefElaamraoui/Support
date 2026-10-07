import 'package:flutter/material.dart';

import '../core/database/app_database.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/online_support/presentation/online_support_screen.dart';
import '../features/physical_support/presentation/physical_support_screen.dart';
import '../features/profile/presentation/profile_settings_screen.dart';

class CarePalsApp extends StatelessWidget {
  const CarePalsApp({required this.appDatabase, super.key});

  final AppDatabase appDatabase;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarePals',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: CarePalsShell(appDatabase: appDatabase),
    );
  }
}

class CarePalsShell extends StatefulWidget {
  const CarePalsShell({required this.appDatabase, super.key});

  final AppDatabase appDatabase;

  @override
  State<CarePalsShell> createState() => _CarePalsShellState();
}

class _CarePalsShellState extends State<CarePalsShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(appDatabase: widget.appDatabase),
      const PhysicalSupportScreen(),
      const OnlineSupportScreen(),
      const ProfileSettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.health_and_safety_outlined), label: 'Physical'),
          NavigationDestination(icon: Icon(Icons.public_outlined), label: 'Online'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
