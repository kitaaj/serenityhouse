import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/main.dart';
import 'package:mental_health_support/models/mood.dart';
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
    on<UpdateMoodEvent>(_onUpdateMood);
  }

  Future<void> _onLoadMoods(
    LoadMoodsEvent event,
    Emitter<MoodState> emit,
  ) async {
    try {
      // Load cached data first
      final cachedMoods = _hive.getCachedMoods();
      if (cachedMoods.isNotEmpty) emit(MoodLoadedState(cachedMoods));

      'Emitting cached moods: $cachedMoods'.log();

      // Then load from Firestore
      if (user == null) throw Exception('User not authenticated');

      _moodsSubscription = _storage.allMoods(user!.id).listen((moods) async {
        'Emitting firestore moods: $moods'.log();

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
        tags: event.mood.tags,
      );
      // Add to Hive
      await _hive.addMood(event.mood.copyWith(id: docRef.id));
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
      if (user == null) throw Exception('User not authenticated');

      await _storage.deleteMood(documentId: event.moodId);
    } catch (e) {
      emit(MoodErrorState('Failed to delete mood: ${e.toString()}'));
    }
  }

  // In MoodBloc's event handlers
  Future<void> _onUpdateMood(
    UpdateMoodEvent event,
    Emitter<MoodState> emit,
  ) async {
    try {
      if (state is MoodLoadedState) {
        final updatedMoods = List<MoodEntry>.from(
          (state as MoodLoadedState).moods,
        );
        final index = updatedMoods.indexWhere(
          (m) => m.id == event.updatedMood.id,
        );
        if (index != -1) {
          // Update local cache
          await _hive.addMood(event.updatedMood);
          // Update Firestore
          await _storage.updateMood(
            documentId: event.updatedMood.id,
            newMood: event.updatedMood.label,
            notes: event.updatedMood.notes,
            tags: event.updatedMood.tags,
          );
          // Update state
          updatedMoods[index] = event.updatedMood;
          emit(MoodLoadedState(updatedMoods));
        }
      }
    } catch (e) {
      emit(MoodErrorState('Update failed: ${e.toString()}'));
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
