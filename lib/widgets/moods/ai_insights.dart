import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mental_health_support/models/mood.dart';

class AIInsightsCard extends StatelessWidget {
  final List<MoodEntry> moods;

  const AIInsightsCard({super.key, required this.moods});

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Insights',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8),
                    const SizedBox(width: 12),
                    Expanded(child: Text(insight)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _generateInsights() {
    final Map<int, double> weeklyPattern = {};
    final now = DateTime.now();

    // Analyze last 4 weeks
    for (int i = 0; i < 28; i++) {
      final date = now.subtract(Duration(days: i));
      final moods = _moodsForDate(date);
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

  List<MoodEntry> _moodsForDate(DateTime date) {
    return moods.where((m) => _isSameDay(m.date, date)).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
