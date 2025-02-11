// ignore_for_file: unnecessary_this

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:mental_health_support/services/cloud/cloud_storage_constants.dart';

part 'message.g.dart';

@HiveType(typeId: 33)
class Message extends HiveObject {
  @HiveField(0)
  final DateTime createdAt;

  @HiveField(1)
  final DateTime updatedAt;

  @HiveField(2)
  final String id;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final bool isUser;

  @HiveField(5)
  final String chatId;

  Message({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.content,
    required this.isUser,
    required this.chatId,
  });

  // Factory constructor to create a Message from a Firestore snapshot
  factory Message.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return Message(
      id: snapshot.id,
      chatId: data[messageChatIdFieldName],
      content: data[contentFieldName] as String,
      isUser: data[isUserFieldName] as bool,
      createdAt: (data[messageCreatedAtFieldName] as Timestamp).toDate(),
      updatedAt: (data[messageUpdatedAtFieldName] as Timestamp).toDate(),
    );
  }

  // Optionally, you can add a toMap method if needed
  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'documentId': id,
      'content': content,
      'isUser': isUser,
    };
  }

  Message copyWith({
    String? id,

    String? chatId,

    String? content,

    DateTime? createdAt,

    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,

      isUser: isUser,

      chatId: chatId ?? this.chatId,

      content: content ?? this.content,

      createdAt: createdAt ?? this.createdAt,

      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
