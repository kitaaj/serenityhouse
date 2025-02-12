import 'package:hive/hive.dart';
import 'package:mental_health_support/models/mood.dart';

class HiveMoodRepository {
  final Box<MoodEntry> _moodBox;

  HiveMoodRepository({required Box<MoodEntry> moodBox}) : _moodBox = moodBox;

  Future<void> cacheMoods(List<MoodEntry> moods) async {
    await _moodBox.clear();
    await _moodBox.addAll(moods);
  }

  List<MoodEntry> getCachedMoods() => _moodBox.values.toList();

  Future<void> addMood(MoodEntry mood) async => await _moodBox.add(mood);

  Future<void> updateMood(String documentId, MoodEntry updatedMood) async {
    final index = _moodBox.values.toList().indexWhere((m) => m.id == documentId);
    if (index != -1) await _moodBox.putAt(index, updatedMood);
  }

  Future<void> deleteMood(String documentId) async {
    final key = _moodBox.values.toList().indexWhere((m) => m.id == documentId);
    if (key != -1) await _moodBox.deleteAt(key);
  }
}