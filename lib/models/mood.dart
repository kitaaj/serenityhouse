import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_health_support/enums/mood_type.dart';
import 'package:mental_health_support/services/cloud/cloud_storage_constants.dart';

part 'mood.g.dart';

@HiveType(typeId: 34)
class MoodEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String label;

  @HiveField(4)
  final String? notes;

  // Add tags field for custom tags
  @HiveField(5)
  final List<String>? tags;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.label,
    this.notes,
    this.tags,
  });

  MoodEntry.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : id = snapshot.id,
      userId = snapshot.data()[ownerUserIdFieldName],
      date = (snapshot.data()[moodDateFieldName] as Timestamp).toDate(),
      label = snapshot.data()[moodFieldName] as String,
      notes = snapshot.data()[moodNotesFieldName] as String,
      tags =
          (snapshot.data()[moodTagsFieldName] as List?)?.cast<String>() ?? [];

  MoodEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? label,
    String? notes,
    List<String>? tags,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      label: label ?? this.label,
      notes: notes ?? this.notes,
      tags: tags ?? List<String>.from(this.tags ?? []),
    );
  }

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
