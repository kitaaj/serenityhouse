import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/services/auth/auth_service.dart';
import 'package:mental_health_support/services/cloud/cloud_journal_entry.dart';
import 'package:mental_health_support/services/cloud/cloud_storage_exceptions.dart';
import 'package:mental_health_support/services/cloud/firebase_cloud_storage.dart';

abstract class JournalEvent {}

class SaveEntryEvent extends JournalEvent {
  final JournalEntry entry;
  SaveEntryEvent(this.entry);
}

abstract class JournalState {}

class JournalInitialState extends JournalState {}

class JournalLoadingState extends JournalState {}

class JournalEntrySavedState extends JournalState {}

class JournalErrorState extends JournalState {
  final String message;
  JournalErrorState(this.message);
}

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final FirebaseCloudStorage _storage;
  JournalBloc(this._storage) : super(JournalInitialState()) {
    on<SaveEntryEvent>(_onSaveEntry);
  }

  Future<void> _onSaveEntry(
    SaveEntryEvent event,
    Emitter<JournalState> emit,
  ) async {
    final user = AuthService.firebase().currentUser;
    if (user == null) {
      emit(JournalErrorState('User not authenticated'));
      return;
    }
    emit(JournalLoadingState());
    try {
      if (event.entry.documentId.isEmpty) {
        await _storage.createJournalEntry(
          userId: user.id,
          content: event.entry.content,
        );
      } else {
        await _storage.updateJournalEntry(
          documentId: event.entry.documentId,
          content: event.entry.content,
        );
      }
      emit(JournalEntrySavedState());
    } on FirebaseException catch (e) {
      emit(JournalErrorState('Firestore error: ${e.message}'));
    } on CouldNotCreateEntryException {
      emit(JournalErrorState('Failed to create or update entry'));
    } catch (e) {
      emit(JournalErrorState('Unexpected error: ${e.toString()}'));
    }
  }
}
