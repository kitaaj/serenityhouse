import 'package:mental_health_support/models/mood.dart';

abstract class MoodState {
  const MoodState();
}

class MoodLoadingState extends MoodState {
  final List<MoodEntry>? previousMoods;
  const MoodLoadingState({this.previousMoods});
}

class MoodLoadedState extends MoodState {
  final List<MoodEntry> moods;
  final Map<DateTime, List<MoodEntry>> moodMap;
  final String mostFrequentMood;
  final int currentStreak;
  final Map<String, Map<String, int>> moodCorrelations;
  final List<String> generatedInsights;

  MoodLoadedState(this.moods)
    : moodMap = _groupMoodsByDate(moods),
      mostFrequentMood = _calculateMostFrequent(moods),
      currentStreak = _calculateCurrentStreak(moods),
      moodCorrelations = _analyzeCorrelations(moods),
      generatedInsights = _generateInsights(moods) {
    assert(generatedInsights != null, 'Generated insights must not be null');
  }

  static Map<DateTime, List<MoodEntry>> _groupMoodsByDate(
    List<MoodEntry> moods,
  ) {
    final map = <DateTime, List<MoodEntry>>{};
    for (final mood in moods) {
      final date = DateTime(mood.date.year, mood.date.month, mood.date.day);
      map.putIfAbsent(date, () => []).add(mood);
    }
    return map;
  }

  static String _calculateMostFrequent(List<MoodEntry> moods) {
    if (moods.isEmpty) return '';
    final counts = <String, int>{};
    for (final mood in moods) {
      counts[mood.emoji] = (counts[mood.emoji] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static int _calculateCurrentStreak(List<MoodEntry> moods) {
    final sorted = List<MoodEntry>.from(moods)
      ..sort((a, b) => b.date.compareTo(a.date));
    if (sorted.isEmpty) return 0;

    int streak = 1;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].date.difference(sorted[i - 1].date).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static Map<String, Map<String, int>> _analyzeCorrelations(
    List<MoodEntry> moods,
  ) {
    final correlations = <String, Map<String, int>>{};
    for (final mood in moods) {
      final hour = mood.date.hour;
      final timeOfDay =
          hour < 12
              ? 'Morning'
              : hour < 17
              ? 'Afternoon'
              : 'Evening';

      correlations.putIfAbsent(
        mood.emoji,
        () => {'Morning': 0, 'Afternoon': 0, 'Evening': 0},
      );

      correlations[mood.emoji]![timeOfDay] =
          (correlations[mood.emoji]![timeOfDay] ?? 0) + 1;
    }
    return correlations;
  }

  static List<String> _generateInsights(List<MoodEntry> moods) {
    final insights = <String>[];
    if (moods.isEmpty) return ['Start logging moods to get insights'];

    final streak = _calculateCurrentStreak(moods);
    if (streak >= 3) {
      insights.add('You\'ve logged moods $streak days in a row!');
    }

    final mostFrequent = _calculateMostFrequent(moods);
    if (mostFrequent.isNotEmpty) {
      insights.add('Your most frequent mood is $mostFrequent');
    }

    if (insights.isEmpty) {
      insights.add('Keep logging to unlock more insights!');
    }

    return insights;
  }
}

class MoodAddedState extends MoodState {
  final MoodEntry addedMood;
  const MoodAddedState(this.addedMood);
}

class MoodErrorState extends MoodState {
  final String message;
  const MoodErrorState(this.message);
}
