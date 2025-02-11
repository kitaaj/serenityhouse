import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_health_support/services/cloud/cloud_storage_constants.dart';

class JournalEntry {
  final String documentId;
  final String userId;
  final String content;

  JournalEntry({
    required this.documentId,
    required this.content,
    required this.userId,
  });

  JournalEntry.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) : documentId = snapshot.id,
      userId = snapshot.data()[ownerUserIdFieldName],
      // date = (snapshot.data()[journalDateFieldName] as Timestamp).toDate(),
      content = snapshot.data()[journalContentFieldName] as String;
}
