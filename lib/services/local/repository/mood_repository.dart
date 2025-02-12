import 'package:mental_health_support/models/mood.dart';

abstract class MoodRepository {
  Stream<List<MoodEntry>> getMoodsStream();
  Future<String> addMood(MoodEntry mood);
  Future<void> updateMood(MoodEntry mood);
  Future<void> deleteMood(String moodId);
  Future<void> cacheMoods(List<MoodEntry> moods);
  List<MoodEntry> getCachedMoods();
}
