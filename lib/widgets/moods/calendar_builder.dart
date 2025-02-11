import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mental_health_support/models/mood.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_event.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_state.dart';
import 'package:mental_health_support/widgets/moods/calendar_day.dart';

class CalendarBuilder extends StatelessWidget {
  // Fixed typo in class name
  final DateTime firstDay;
  final int daysInMonth;

  const CalendarBuilder({
    super.key,
    required this.firstDay,
    required this.daysInMonth,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final date = firstDay.add(Duration(days: index));
          return CalendarDay(
            date: date,
            onPressed: () => _showDailyMood(context, date),
          );
        }, childCount: daysInMonth),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
      ),
    );
  }

  void _showDailyMood(BuildContext context, DateTime date) {
    final moods =
        context
            .select<MoodBloc, List<MoodEntry>>(
              (bloc) =>
                  bloc.state is MoodLoadedState
                      ? (bloc.state as MoodLoadedState).moods
                      : [],
            )
            .where((mood) => _isSameDay(mood.date, date))
            .toList();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(DateFormat('EEEE, MMM d').format(date)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (moods.isEmpty)
                  const Text('No mood entries')
                else
                  ...moods.map(
                    (mood) => ListTile(
                      leading: Text(mood.emoji),
                      title: Text(mood.label),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed:
                            () => context.read<MoodBloc>().add(
                              DeleteMoodEvent(mood.id),
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
