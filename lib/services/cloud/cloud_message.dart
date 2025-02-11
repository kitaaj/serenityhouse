import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_health_support/services/cloud/cloud_storage_constants.dart';

class Message {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String documentId;
  final String content;
  final bool isUser;

  Message({
    required this.createdAt,
    required this.updatedAt,
    required this.documentId,
    required this.content,
    required this.isUser,
  });

  Message.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      content = snapshot.data()[contentFieldName] as String,
      isUser = snapshot.data()[isUserFieldName] as bool,
      createdAt =
          (snapshot.data()[messageCreatedAtFieldName] as Timestamp).toDate(),
      updatedAt =
          (snapshot.data()[messageUpdatedAtFieldName] as Timestamp).toDate();
}
