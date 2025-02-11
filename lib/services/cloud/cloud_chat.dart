// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart' show immutable;
// import 'package:mental_health_support/services/cloud/cloud_storage_constants.dart';

// @immutable
// class Chat {
//   final String userId;
//   final String chatId;
//   final String title;
//   final String? latestMessage;
//   final int unreadCount;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final int messageCount;

//   const Chat({
//     required this.createdAt,
//     required this.updatedAt,
//     required this.userId,
//     required this.chatId,
//     required this.title,
//     this.latestMessage,
//     this.unreadCount = 0,
//     required this.messageCount,
//   });

//   factory Chat.fromSnapshot(QueryDocumentSnapshot snapshot) {
//     final data = snapshot.data() as Map<String, dynamic>;
//     return Chat(
//       userId: data[ownerUserIdFieldName] as String,
//       chatId: snapshot.id,
//       title: data[chatTitleFieldName] ?? 'New Chat',
//       latestMessage: data[latestMessageFieldName] as String?,
//       unreadCount: data[unreadCountFieldName] as int? ?? 0,
//       createdAt: (data[chatCreatedAtFieldName] as Timestamp).toDate(),
//       updatedAt: (data[chatUpdatedAtFieldName] as Timestamp).toDate(),
//       messageCount: data[messageCountFieldName] as int? ?? 0,
//     );
//   }
// }
