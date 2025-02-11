import 'package:equatable/equatable.dart';
import 'package:mental_health_support/models/mood.dart';

abstract class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object> get props => [];
}

class CheckAchievementsEvent extends AchievementEvent {
  final List<MoodEntry> moods;

  const CheckAchievementsEvent(this.moods);

  @override
  List<Object> get props => [moods];
}

class ResetAchievementsEvent extends AchievementEvent {}
class SeedDummyAchievementsEvent extends AchievementEvent{}