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
    // First yield cached moods
    final cachedMoods = _hive.getCachedMoods();
    if (cachedMoods.isNotEmpty) {
      yield cachedMoods;
    }

    // Then stream from Firestore and update cache
    yield* _firestore.allMoods(_userId).asyncMap((moods) async {
      await _hive.cacheMoods(moods.toList());
      return moods.toList();
    });
  }

  @override
  Future<String> addMood(MoodEntry mood) async {
    final docRef = await _firestore.createMood(
      userId: _userId,
      label: mood.label,
      notes: mood.notes,
      tags: mood.tags,
    );
    await _hive.addMood(mood.copyWith(id: docRef.id));
    return docRef.id;
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
