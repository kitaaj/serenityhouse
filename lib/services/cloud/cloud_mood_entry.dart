import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:mental_health_support/enums/mood_type.dart';
import 'package:mental_health_support/services/cloud/cloud_storage_constants.dart';

@immutable
class MoodEntry {
  final String documentId;
  final String userId;
  final DateTime date; 
  final String label;

  const MoodEntry({
    required this.documentId,
    required this.date, 
    required this.label,
    required this.userId,
  });

  MoodEntry.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      userId = snapshot.data()[ownerUserIdFieldName],
      date =
          (snapshot.data()[moodDateFieldName] as Timestamp)
              .toDate(), 
      label = snapshot.data()[moodFieldName] as String;

  // Add a method to get the color based on the mood using MoodType enum
  Color get color {
    final moodType = MoodType.values.firstWhere(
      (m) => m.label.toLowerCase() == label.toLowerCase(),
      orElse: () => MoodType.neutral, 
    );
    return moodType.color;
  }

  // Optionally add a getter for the emoji
  String get emoji {
    final moodEmoji = MoodType.values.firstWhere(
      (m) => m.label.toLowerCase() == label.toLowerCase(),
      orElse: () => MoodType.neutral, // Default to neutral if no match found
    );
    return moodEmoji.emoji;
  }
}
