import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/models/mood.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_event.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_state.dart';
import 'package:mental_health_support/services/local/repository/mood_repository.dart';

class MoodBloc extends Bloc<MoodEvent, MoodState> {
  final MoodRepository _repository;
  StreamSubscription? _moodsSubscription;

  MoodBloc(this._repository) : super(MoodLoadingState()) {
    on<LoadMoodsEvent>(_onLoadMoods);
    on<AddMoodEvent>(_onAddMood);
    on<DeleteMoodEvent>(_onDeleteMood);
    on<UpdateMoodEvent>(_onUpdateMood);
  }

  Future<void> _onLoadMoods(
    LoadMoodsEvent event,
    Emitter<MoodState> emit,
  ) async {
    _moodsSubscription?.cancel();
    await emit.forEach<List<MoodEntry>>(
      _repository.getMoodsStream(),
      onData: (moods) => MoodLoadedState(moods),
      onError: (error, _) => MoodErrorState(error.toString()),
    );
  }

  Future<void> _onAddMood(AddMoodEvent event, Emitter<MoodState> emit) async {
    try {
      await _repository.addMood(event.mood);
      add(LoadMoodsEvent());
    } catch (e) {
      emit(MoodErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteMood(
    DeleteMoodEvent event,
    Emitter<MoodState> emit,
  ) async {
    try {
      await _repository.deleteMood(event.moodId);
      add(LoadMoodsEvent());
    } catch (e) {
      emit(MoodErrorState('Failed to delete mood: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateMood(
    UpdateMoodEvent event,
    Emitter<MoodState> emit,
  ) async {
    try {
      await _repository.updateMood(event.updatedMood);
      add(LoadMoodsEvent());
    } catch (e) {
      emit(MoodErrorState('Update failed: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _moodsSubscription?.cancel();
    return super.close();
  }
}
