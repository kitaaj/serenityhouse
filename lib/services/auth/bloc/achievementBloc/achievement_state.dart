import 'package:equatable/equatable.dart';
import 'package:mental_health_support/models/achievement.dart';

abstract class AchievementState extends Equatable {
  const AchievementState();

  @override
  List<Object> get props => [];
}

class AchievementInitial extends AchievementState {}

class AchievementsLoading extends AchievementState {}

class AchievementsLoaded extends AchievementState {
  final List<Achievement> achievements;

  const AchievementsLoaded(this.achievements);

  @override
  List<Object> get props => [achievements];
}

class AchievementsError extends AchievementState {
  final String message;

  const AchievementsError(this.message);

  @override
  List<Object> get props => [message];
}
