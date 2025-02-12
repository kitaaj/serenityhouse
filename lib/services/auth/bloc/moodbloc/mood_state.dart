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

  MoodLoadedState(this.moods) : moodMap = _groupMoodsByDate(moods);

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
}

class MoodErrorState extends MoodState {
  final String message;
  const MoodErrorState(this.message);
}
