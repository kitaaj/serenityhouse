import 'package:flutter/material.dart';
import 'package:mental_health_support/helpers/constants/mood_colors.dart';

enum MoodType {
  amazing('😁', 'Amazing', amazingColor,
      '37i9dQZF1DXdPec7aLTmlC'), // Example Playlist ID
  happy('😊', 'Happy', happyColor,
      '37i9dQZF1DXdPec7aLTmlC'), // Example Playlist ID
  calm('😌', 'Calm', calmColor,
      '37i9dQZF1DX4WYpdgoIcn6'), // Example Playlist ID
  energetic('💪', 'Energetic', energeticColor,
      '37i9dQZF1DX3rxVfibe1L0'), // Example Playlist ID
  neutral('😐', 'Neutral', neutralColor, null),
  sad('😔', 'Sad', sadColor,
      '37i9dQZF1DWXRqgorJj26U'), // Example Playlist ID
  angry('😡', 'Angry', angryColor, null),
  anxious('😰', 'Anxious', anxiousColor,
      '37i9dQZF1DX7KNKjOK0o75'), // Example Playlist ID
  relaxed('🥰', 'Relaxed', relaxedColor,
      '37i9dQZF1DX4sWSpwq3LiO'); // Example Playlist ID

  const MoodType(
      this.emoji, this.label, this.color, this.spotifyPlaylistId);

  final String emoji;
  final String label;
  final Color color;
  final String? spotifyPlaylistId;

  static MoodType fromLabel(String label) {
    return values.firstWhere(
      (m) => m.label.toLowerCase() == label.toLowerCase(),
      orElse: () => MoodType.neutral, 
    );
  }

  static MoodType fromEmoji(String emoji) {
    return values.firstWhere(
      (m) => m.emoji == emoji,
      orElse: () => MoodType.neutral, 
    );
  }
}