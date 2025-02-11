import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'achievement.g.dart'; // Generated file

@HiveType(typeId: 35)
class Achievement extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int codePoint; // For IconData serialization

  @HiveField(4)
  final String? fontFamily; // For IconData serialization

  @HiveField(5)
  final bool unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.codePoint,
    required this.fontFamily,
    this.unlocked = false,
  });

  factory Achievement.fromIconData({
    required String id,
    required String title,
    required String description,
    required IconData icon,
    bool unlocked = false,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      codePoint: icon.codePoint,
      fontFamily: icon.fontFamily,
      unlocked: unlocked,
    );
  }

  IconData get icon => IconData(
    codePoint,
    fontFamily: fontFamily,
    fontPackage: IconData(codePoint).fontPackage,
  );

  factory Achievement.fromMap(Map<String, dynamic> map) => Achievement.fromIconData(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    icon: IconData(map['codePoint'], fontFamily: map['fontFamily']),
    unlocked: map['unlocked'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'codePoint': codePoint,
    'fontFamily': fontFamily,
    'unlocked': unlocked,
  };

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    bool? unlocked,
  }) => Achievement.fromIconData(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    icon: icon ?? this.icon,
    unlocked: unlocked ?? this.unlocked,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Achievement &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
