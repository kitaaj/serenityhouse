import 'package:hive/hive.dart';
import 'package:mental_health_support/helpers/dummy_achievements.dart';
import 'package:mental_health_support/models/achievement.dart';

class AchievementRepository {
  final Box<Achievement> _achievementBox;

  AchievementRepository({required Box<Achievement> achievementBox})
    : _achievementBox = achievementBox;

  Future<List<Achievement>> getAchievements() async {
    return _achievementBox.values.toList();
  }

  Future<void> saveAchievement(Achievement achievement) async {
    final existing = _achievementBox.values.firstWhere(
      (a) => a.id == achievement.id,
      orElse: () => achievement,
    );

    if (existing.key != null) {
      await _achievementBox.put(existing.key!, achievement);
    } else {
      await _achievementBox.add(achievement);
    }
  }

  Future<void> addAll(List<Achievement> achievements) async {
    final Map<dynamic, Achievement> updates = {};
    final List<Achievement> additions = [];

    for (final achievement in achievements) {
      final existing = _achievementBox.values.firstWhere(
        (a) => a.id == achievement.id,
        orElse: () => achievement,
      );

      if (existing.key != null) {
        updates[existing.key!] = achievement;
      } else {
        additions.add(achievement);
      }
    }

    if (updates.isNotEmpty) {
      await _achievementBox.putAll(updates);
    }
    if (additions.isNotEmpty) {
      await _achievementBox.addAll(additions);
    }
  }

   Future<void> seedDummyAchievements() async {
    await addAll(dummyAchievements);
  }
  Future<void> clearAchievements() async {
    await _achievementBox.clear();
  }
}
