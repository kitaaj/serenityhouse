import 'package:mental_health_support/models/mood.dart';

abstract class MoodEvent {}

class LoadMoodsEvent extends MoodEvent {}

class AddMoodEvent extends MoodEvent {
  final MoodEntry mood;
  AddMoodEvent(this.mood);
}

class DeleteMoodEvent extends MoodEvent {
  final String moodId;
  DeleteMoodEvent(this.moodId);
}

class MoodsUpdatedEvent extends MoodEvent {
  final List<MoodEntry> moods;
  MoodsUpdatedEvent(this.moods);
}

class UpdateMoodEvent extends MoodEvent {
  final MoodEntry updatedMood;

  UpdateMoodEvent(this.updatedMood);
}

class MoodErrorEvent extends MoodEvent {
 String error;

  MoodErrorEvent(this.error);
}
