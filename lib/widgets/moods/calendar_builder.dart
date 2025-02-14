import 'package:flutter/material.dart';
import 'package:mental_health_support/widgets/moods/calendar_day.dart';
import 'package:mental_health_support/widgets/moods/daily_mood.dart';

class CalendarBuilder extends StatelessWidget {
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
      padding: const EdgeInsets.all(8.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final date = firstDay.add(Duration(days: index));
          return CalendarDay(
            date: date,
            onPressed: () => showDailyMood(context, date),
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
}
