import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/achievementBloc/achievement_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/achievementBloc/achievement_event.dart';

class DummyAchievementButton extends StatelessWidget {
  const DummyAchievementButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Dispatch the event to seed dummy achievements.
        context.read<AchievementBloc>().add(SeedDummyAchievementsEvent());
      },
      child: const Text('Load Dummy Achievements'),
    );
  }
}
