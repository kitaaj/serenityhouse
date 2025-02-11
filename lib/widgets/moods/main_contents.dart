import 'package:flutter/material.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_state.dart';
import 'package:mental_health_support/widgets/moods/ai_insights.dart';
import 'package:mental_health_support/widgets/moods/calendar_builder.dart';
import 'package:mental_health_support/widgets/moods/mood_achievements.dart';
import 'package:mental_health_support/widgets/moods/mood_app_bar.dart';
import 'package:mental_health_support/widgets/moods/mood_legend.dart';
import 'package:mental_health_support/widgets/moods/mood_statistics.dart';
import 'package:mental_health_support/widgets/moods/mood_timeline.dart';

class MainContent extends StatelessWidget {
  final MoodLoadedState state;
  const MainContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final firstDay = DateTime(today.year, today.month, 1);
    final lastDay = DateTime(today.year, today.month + 1, 0);
    final daysInMonth = lastDay.day;
    return CustomScrollView(
      slivers: [
        MoodSliverAppBar(context: context),

        CalendarBuilder(firstDay: firstDay, daysInMonth: daysInMonth),

        MoodStatistics(),
        MoodLegend(),
        SliverToBoxAdapter(child: MoodTimeline(moods: state.moods)),
        MoodAchievements(),
        SliverToBoxAdapter(child: AIInsightsCard(moods: state.moods)),
      ],
    );
  }
}
