import 'package:mental_health_support/models/mood.dart';

bool isNegativeMood(MoodEntry mood) {
  const negativeMoods = {'😞', '😢', '😡'}; // Update with your negative emojis
  return negativeMoods.contains(mood.emoji);
}