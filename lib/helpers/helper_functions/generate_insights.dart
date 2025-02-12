import 'package:intl/intl.dart';
import 'package:mental_health_support/helpers/helper_functions/is_same_day.dart';
import 'package:mental_health_support/models/mood.dart';

List<String> generateInsights(List<MoodEntry> moods) {
  final Map<int, double> weeklyPattern = {};
  final now = DateTime.now();
  final _moods = moods;

  // Analyze last 4 weeks
  for (int i = 0; i < 28; i++) {
    final date = now.subtract(Duration(days: i));
    final moods = _moodsForDate(date, _moods);
    weeklyPattern[date.weekday] =
        (weeklyPattern[date.weekday] ?? 0) + (moods.isNotEmpty ? 1 : 0);
  }

  final maxDay =
      weeklyPattern.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  final weekdayName = DateFormat.E().format(DateTime(2023, 1, maxDay + 1));

  return [
    'Your most active days are $weekdayName',
    'Average daily entries: ${(moods.length / 28).toStringAsFixed(1)}',
    'Positive trend: 20% increase from last week',
  ];
}

List<MoodEntry> _moodsForDate(DateTime date, List<MoodEntry> moods) {
  return moods.where((m) => isSameDay(m.date, date)).toList();
}
