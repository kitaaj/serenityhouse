// models/chat.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_health_support/services/cloud/cloud_storage_constants.dart';
import 'package:hive/hive.dart';

part 'chat.g.dart'; // Required for Hive code generation

@HiveType(typeId: 32)
class Chat extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String chatId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String? latestMessage;

  @HiveField(4)
  final int unreadCount;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final int messageCount;

  Chat({
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.chatId,
    required this.title,
    this.latestMessage,
    this.unreadCount = 0,
    required this.messageCount,
  });

  /// Factory constructor to create a Chat instance from Firestore snapshot
  factory Chat.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Chat(
      userId: data[ownerUserIdFieldName] as String? ?? '',
      chatId: snapshot.id,
      title: data[chatTitleFieldName] ?? 'New Chat',
      latestMessage: data[latestMessageFieldName] as String?,
      unreadCount: data[unreadCountFieldName] as int? ?? 0,
      createdAt:
          (data[chatCreatedAtFieldName] as Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt:
          (data[chatUpdatedAtFieldName] as Timestamp?)?.toDate() ??
          DateTime.now(),
      messageCount: data[messageCountFieldName] as int? ?? 0,
    );
  }

  /// Converts the Chat instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      ownerUserIdFieldName: userId,
      chatTitleFieldName: title,
      latestMessageFieldName: latestMessage,
      unreadCountFieldName: unreadCount,
      chatCreatedAtFieldName: Timestamp.fromDate(createdAt),
      chatUpdatedAtFieldName: Timestamp.fromDate(updatedAt),
      messageCountFieldName: messageCount,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> data, String id) {
    return Chat(
      userId: data[ownerUserIdFieldName] as String,
      chatId: id,
      title: data[chatTitleFieldName] as String? ?? 'New Chat',
      latestMessage: data[latestMessageFieldName] as String?,
      unreadCount: data[unreadCountFieldName] as int? ?? 0,
      createdAt: (data[chatCreatedAtFieldName] as Timestamp).toDate(),
      updatedAt: (data[chatUpdatedAtFieldName] as Timestamp).toDate(),
      messageCount: data[messageCountFieldName] as int? ?? 0,
    );
  }

  Chat copyWith({
    String? chatId,

    String? userId,

    String? latestMessage,

    DateTime? updatedAt,

    int? messageCount,

    int? unreadCount,
  }) {
    return Chat(
      chatId: chatId ?? this.chatId,
      title: title,

      userId: userId ?? this.userId,

      latestMessage: latestMessage ?? this.latestMessage,
      createdAt: createdAt,

      updatedAt: updatedAt ?? this.updatedAt,

      messageCount: messageCount ?? this.messageCount,

      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
