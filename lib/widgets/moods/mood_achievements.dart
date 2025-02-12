import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/helpers/logger.dart';
import 'package:mental_health_support/models/achievement.dart';
import 'package:mental_health_support/widgets/moods/achievement_card.dart';
import 'package:mental_health_support/services/auth/bloc/achievementBloc/achievement_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/achievementBloc/achievement_state.dart';
import 'package:mental_health_support/services/auth/bloc/achievementBloc/achievement_event.dart';

class MoodAchievements extends StatefulWidget {
  const MoodAchievements({super.key});

  @override
  State<MoodAchievements> createState() => _MoodAchievementsState();
}

class _MoodAchievementsState extends State<MoodAchievements> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementBloc>().add(SeedDummyAchievementsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            BlocBuilder<AchievementBloc, AchievementState>(
              builder: (context, achievementState) {
                if (achievementState is AchievementsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (achievementState is AchievementsError) {
                  return Text('Error: ${achievementState.message}');
                }
                if (achievementState is AchievementsLoaded) {
                  'Logging from the MoodAchievements class file: We are here ${achievementState.achievements.map((element) => Achievement(id: element.id, title: element.title, description: element.description, codePoint: element.codePoint, fontFamily: element.fontFamily))}'
                      .log();
                  return _buildAchievementsGrid(achievementState.achievements);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsGrid(List<Achievement> achievements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: achievements.length,
      itemBuilder:
          (context, index) => AchievementCard(achievement: achievements[index]),
    );
  }
}
