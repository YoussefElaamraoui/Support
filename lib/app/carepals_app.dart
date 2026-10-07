import 'package:flutter/material.dart';

import '../core/database/app_database.dart';
import '../core/models/user_profile.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/care_bottom_nav.dart';
import '../core/widgets/care_menu_drawer.dart';
import '../features/home/application/mood_controller.dart';
import '../features/home/application/session_controller.dart';
import '../features/home/application/wellbeing_controller.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/online_support/presentation/online_support_screen.dart';
import '../features/physical_support/presentation/physical_support_screen.dart';
import '../features/profile/application/profile_controller.dart';
import '../features/profile/presentation/profile_settings_screen.dart';

class CarePalsApp extends StatelessWidget {
  const CarePalsApp({
    required this.appDatabase,
    this.initialProfile = UserProfile.fallback,
    this.clock,
    super.key,
  });

  final AppDatabase appDatabase;

  /// Profile shown until the stored one is loaded (and used when none is saved).
  final UserProfile initialProfile;

  /// Injectable clock (handy for tests / screenshots).
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarePals',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: CarePalsShell(appDatabase: appDatabase, initialProfile: initialProfile, clock: clock),
    );
  }
}

class CarePalsShell extends StatefulWidget {
  const CarePalsShell({
    required this.appDatabase,
    this.initialProfile = UserProfile.fallback,
    this.clock,
    super.key,
  });

  final AppDatabase appDatabase;
  final UserProfile initialProfile;
  final DateTime Function()? clock;

  @override
  State<CarePalsShell> createState() => _CarePalsShellState();
}

class _CarePalsShellState extends State<CarePalsShell> {
  int _index = 0;

  late final profile = ProfileController(widget.appDatabase, initial: widget.initialProfile);
  late final moods = MoodController(widget.appDatabase, clock: widget.clock);
  late final session = SessionController(widget.appDatabase, clock: widget.clock);
  late final wellbeing = WellbeingController(widget.appDatabase);

  @override
  void initState() {
    super.initState();
    profile.load();
    moods.load();
    session.load();
    wellbeing.load();
  }

  @override
  void dispose() {
    profile.dispose();
    moods.dispose();
    session.dispose();
    wellbeing.dispose();
    super.dispose();
  }

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        profileController: profile,
        moodController: moods,
        sessionController: session,
        wellbeingController: wellbeing,
      ),
      PhysicalSupportScreen(profileController: profile, appDatabase: widget.appDatabase),
      OnlineSupportScreen(profileController: profile),
      ProfileSettingsScreen(profileController: profile),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      endDrawer: ListenableBuilder(
        listenable: profile,
        builder: (context, _) => CareMenuDrawer(
          profile: profile.profile,
          selectedIndex: _index,
          onSelected: _select,
        ),
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: CareBottomNav(selectedIndex: _index, onSelected: _select),
    );
  }
}
