import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/main.dart';
import 'package:mental_health_support/models/achievement.dart';
import 'package:mental_health_support/services/auth/bloc/achievementBloc/achievement_event.dart';
import 'package:mental_health_support/widgets/moods/achievement_card.dart';
import 'package:mental_health_support/services/auth/bloc/achievementBloc/achievement_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/achievementBloc/achievement_state.dart';

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
            const Text(
              'Achievements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  'We are here ${achievementState.achievements.toString()}'
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
