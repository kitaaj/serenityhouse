import 'package:flutter/material.dart';
import 'package:mental_health_support/models/achievement.dart';

final List<Achievement> dummyAchievements = [
  Achievement.fromIconData(
    id: 'dummy_1',
    title: 'First Steps',
    description: 'Log your first mood entry!',
    icon: Icons.directions_walk,
    unlocked: true,
  ),
  Achievement.fromIconData(
    id: 'dummy_2',
    title: 'Keep it Going',
    description: 'Log moods for 5 consecutive days.',
    icon: Icons.accessibility_new,
    unlocked: false,
  ),
  Achievement.fromIconData(
    id: 'dummy_3',
    title: 'Mood Explorer',
    description: 'Try logging different moods for variety!',
    icon: Icons.explore,
    unlocked: false,
  ),
];
