import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/care_top_bar.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../profile/application/profile_controller.dart';
import '../application/mood_controller.dart';
import '../application/quiz_questions.dart';
import '../application/session_controller.dart';
import '../application/wellbeing_controller.dart';
import 'widgets/mood_calendar.dart';
import 'widgets/mood_selector.dart';
import 'widgets/quiz_card.dart';
import 'widgets/session_card.dart';
import 'widgets/stat_cards.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.profileController,
    required this.moodController,
    required this.sessionController,
    required this.wellbeingController,
    super.key,
  });

  final ProfileController profileController;
  final MoodController moodController;
  final SessionController sessionController;
  final WellbeingController wellbeingController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          ListenableBuilder(
            listenable: profileController,
            builder: (context, _) {
              final profile = profileController.profile;
              return CareTopBar(
                leading: ProfileAvatar(profile: profile, size: 44),
                bottomBorder: false,
                menuStyle: MenuButtonStyle.square,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Welcome back',
                        style: AppTypography.labelSm.copyWith(fontSize: 13, color: AppColors.onSurfaceVariant)),
                    Text(
                      profile.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListenableBuilder(
                        listenable: Listenable.merge([profileController, moodController]),
                        builder: (context, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              DateFmt.medium(moodController.today),
                              style: AppTypography.labelSm.copyWith(fontSize: 13, color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hello ${profileController.profile.firstName}! How are you feeling today?',
                              style: AppTypography.pageHeadline(context),
                            ),
                            const SizedBox(height: 24),
                            MoodSelector(
                              selected: moodController.todaysMood,
                              onSelected: (mood) => moodController.setMood(moodController.today, mood),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SessionCard(controller: sessionController),
                      const SizedBox(height: 16),
                      StatCards(controller: wellbeingController),
                      const SizedBox(height: 16),
                      QuizCard(
                        questions: quizQuestions,
                        onCompleted: wellbeingController.applyQuizAnswers,
                      ),
                      const SizedBox(height: 16),
                      MoodCalendar(controller: moodController),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
