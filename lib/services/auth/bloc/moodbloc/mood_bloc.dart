import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/services/auth/auth_service.dart';
import 'package:mental_health_support/services/cloud/firebase_cloud_storage.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_event.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_state.dart';
import 'package:mental_health_support/services/local/repository/mood_repository.dart';

class MoodBloc extends Bloc<MoodEvent, MoodState> {
  final FirebaseCloudStorage _storage;
  final HiveMoodRepository _hive;
  StreamSubscription? _moodsSubscription;
  final user = AuthService.firebase().currentUser;

  MoodBloc(this._storage, this._hive) : super(MoodLoadingState()) {
    on<LoadMoodsEvent>(_onLoadMoods);
    on<AddMoodEvent>(_onAddMood);
    on<DeleteMoodEvent>(_onDeleteMood);
    on<MoodsUpdatedEvent>(_onMoodsUpdated);
  }

  Future<void> _onLoadMoods(
    LoadMoodsEvent event,
    Emitter<MoodState> emit,
  ) async {
    try {
      // Load cached data first
      final cachedMoods = _hive.getCachedMoods();
      if (cachedMoods.isNotEmpty) emit(MoodLoadedState(cachedMoods));

      // Then load from Firestore
      if (user == null) throw Exception('User not authenticated');

      _moodsSubscription = _storage.allMoods(user!.id).listen((moods) async {
        await _hive.cacheMoods(moods.toList());
        add(MoodsUpdatedEvent(moods.toList()));
      });
    } catch (e) {
      emit(MoodErrorState(e.toString()));
    }
  }

  Future<void> _onAddMood(AddMoodEvent event, Emitter<MoodState> emit) async {
    try {
      if (user == null) throw Exception('User not authenticated');

      // Add to Firestore
      final docRef = await _storage.createMood(
        userId: user!.id,
        label: event.mood.label,
        notes: event.mood.notes,
        tags: event.mood.tags
      );
      // Add to Hive
      await _hive.addMood(event.mood.copyWith(id: docRef.id));
    } catch (e) {
      emit(MoodErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteMood(
    DeleteMoodEvent event,
    Emitter<MoodState> emit,
  ) async {
    try {
      if (user == null) throw Exception('User not authenticated');

      await _storage.deleteMood(documentId: event.moodId);
    } catch (e) {
      emit(MoodErrorState('Failed to delete mood: ${e.toString()}'));
    }
  }

  Future<void> _onMoodsUpdated(
    MoodsUpdatedEvent event,
    Emitter<MoodState> emit,
  ) async {
    emit(MoodLoadedState(event.moods));
  }

  @override
  Future<void> close() {
    _moodsSubscription?.cancel();
    return super.close();
  }
}
