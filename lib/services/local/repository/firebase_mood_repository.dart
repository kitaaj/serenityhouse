import 'package:mental_health_support/helpers/logger.dart';
import 'package:mental_health_support/models/mood.dart';
import 'package:mental_health_support/services/cloud/firebase_cloud_storage.dart';
import 'package:mental_health_support/services/local/repository/hive_mood_repository.dart';
import 'package:mental_health_support/services/local/repository/mood_repository.dart';

class FirebaseMoodRepository implements MoodRepository {
  final FirebaseCloudStorage _firestore;
  final HiveMoodRepository _hive;
  final String _userId;

  FirebaseMoodRepository({
    required FirebaseCloudStorage firestore,
    required HiveMoodRepository hive,
    required String userId,
  }) : _firestore = firestore,
       _hive = hive,
       _userId = userId;

   @override
  Stream<List<MoodEntry>> getMoodsStream() async* {
    try {
      final cachedMoods = _hive.getCachedMoods();
      if (cachedMoods.isNotEmpty) {
        yield cachedMoods;
      }

      yield* _firestore.allMoods(_userId).asyncMap((moods) async {
        try {
          await _hive.cacheMoods(moods.toList());
          ('Updated local mood cache').log();
        } catch (e) {
      ('Failed to update local cache', e).log();
        }
        return moods.toList();
      }).handleError((error) {
        'Firestore stream error, error'.log();
        if (cachedMoods.isNotEmpty) {
          return cachedMoods;
        }
        throw error;
      });
    } catch (e) {
      'Failed to initialize mood stream, $e'.log();
      rethrow;
    }
  }

  @override
  Future<String> addMood(MoodEntry mood) async {
    try {
      final docRef = await _firestore.createMood(
        userId: _userId,
        label: mood.label,
        notes: mood.notes,
        tags: mood.tags,
      );
      
      final newMood = mood.copyWith(id: docRef.id);
      await _hive.addMood(newMood);
      
      'Added mood ${docRef.id}'.log();
      return docRef.id;
    } catch (e) {
      'Failed to add mood, $e'.log();
      rethrow;
    }
  }

  @override
  Future<void> updateMood(MoodEntry mood) async {
    await _firestore.updateMood(
      documentId: mood.id,
      newMood: mood.label,
      notes: mood.notes,
      tags: mood.tags,
    );
    await _hive.updateMood(mood.id, mood);
  }

  @override
  Future<void> deleteMood(String moodId) async {
    await _firestore.deleteMood(documentId: moodId);
    await _hive.deleteMood(moodId);
  }

  @override
  Future<void> cacheMoods(List<MoodEntry> moods) => _hive.cacheMoods(moods);

  @override
  List<MoodEntry> getCachedMoods() => _hive.getCachedMoods();
}
