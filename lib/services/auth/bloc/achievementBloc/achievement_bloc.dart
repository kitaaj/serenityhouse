import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/models/mood.dart';
import 'package:mental_health_support/models/achievement.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_state.dart';
import 'package:mental_health_support/services/local/repository/achievement_repository.dart';
import 'package:mental_health_support/services/auth/bloc/achievementBloc/achievement_state.dart';
import 'package:mental_health_support/services/auth/bloc/achievementBloc/achievement_event.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  final MoodBloc _moodBloc;
  final AchievementRepository _repository;
  StreamSubscription? _moodSubscription;

  AchievementBloc(this._moodBloc, this._repository)
    : super(AchievementInitial()) {
    on<CheckAchievementsEvent>(_onCheckAchievements);
    on<ResetAchievementsEvent>(_onResetAchievements);
    _moodSubscription = _moodBloc.stream.listen((state) {
      if (state is MoodLoadedState) {
        add(CheckAchievementsEvent(state.moods));
      }
    });
    on<SeedDummyAchievementsEvent>((event, emit) async {
      try {
        emit(AchievementsLoading());
        await _repository.seedDummyAchievements();
        final achievements = await _repository.getAchievements();
        emit(AchievementsLoaded(achievements));
      } catch (e) {
        emit(
          AchievementsError(
            'Failed to seed dummy achievements: ${e.toString()}',
          ),
        );
      }
    });
  }

  Future<void> _onCheckAchievements(
    CheckAchievementsEvent event,
    Emitter<AchievementState> emit,
  ) async {
    try {
      emit(AchievementsLoading());

      final List<Achievement> achievements = [];
      final now = DateTime.now();

      final existing = await _repository.getAchievements();

      // 7-Day Streak
      final streak = _calculateStreak(event.moods);
      if (streak >= 7) {
        achievements.add(
          _getOrCreateAchievement(
            existing,
            'streak_7',
            title: '7-Day Streak 🔥',
            description: 'Logged your mood for $streak consecutive days',
            icon: Icons.local_fire_department,
          ),
        );
      }
      // Monthly Completion
      if (_isMonthComplete(event.moods, now)) {
        achievements.add(
          Achievement.fromIconData(
            id: '',
            title: 'Monthly Completion 🌟',
            description: 'Logged moods for every day this month',
            icon: Icons.star,
            unlocked: true,
          ),
        );
      }

      // Variety Seeker
      final uniqueMoods = event.moods.map((m) => m.label).toSet().length;
      if (uniqueMoods >= 5) {
        achievements.add(
          Achievement.fromIconData(
            id: '',
            title: 'Variety Seeker 🎨',
            description: 'Used $uniqueMoods different mood types',
            icon: Icons.palette,
            unlocked: true,
          ),
        );
      }
      await _repository.addAll(achievements);
      emit(AchievementsLoaded(achievements));
    } catch (e) {
      emit(AchievementsError('Failed to load achievements: ${e.toString()}'));
    }
  }

  Achievement _getOrCreateAchievement(
    List<Achievement> existing,
    String id, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    return existing.firstWhere(
      (a) => a.id == id,
      orElse:
          () => Achievement.fromIconData(
            id: id,
            title: title,
            description: description,
            icon: icon,
          ),
    );
  }

  void _onResetAchievements(
    ResetAchievementsEvent event,
    Emitter<AchievementState> emit,
  ) {
    emit(AchievementInitial());
  }

  int _calculateStreak(List<MoodEntry> moods) {
    if (moods.isEmpty) return 0;

    final sorted = List<MoodEntry>.from(moods)
      ..sort((a, b) => b.date.compareTo(a.date));

    DateTime currentDate = DateTime.now();
    int streak = 0;
    int index = 0;

    while (index < sorted.length) {
      final entryDate = sorted[index].date;
      if (!_isSameDay(entryDate, currentDate)) break;

      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
      index++;

      // Skip duplicates for the same day
      while (index < sorted.length &&
          _isSameDay(
            sorted[index].date,
            currentDate.add(const Duration(days: 1)),
          )) {
        index++;
      }
    }

    return streak;
  }

  bool _isMonthComplete(List<MoodEntry> moods, DateTime referenceDate) {
    final firstDay = DateTime(referenceDate.year, referenceDate.month, 1);
    final lastDay = DateTime(referenceDate.year, referenceDate.month + 1, 0);

    final loggedDays =
        moods
            .where(
              (m) =>
                  m.date.isAfter(firstDay.subtract(const Duration(days: 1))) &&
                  m.date.isBefore(lastDay.add(const Duration(days: 1))),
            )
            .map((m) => DateTime(m.date.year, m.date.month, m.date.day))
            .toSet();

    for (var day = 0; day < lastDay.day; day++) {
      final currentDay = firstDay.add(Duration(days: day));
      if (!loggedDays.contains(currentDay)) return false;
    }

    return true;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Future<void> close() {
    _moodSubscription?.cancel();
    return super.close();
  }
}
