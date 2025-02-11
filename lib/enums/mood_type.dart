import 'dart:ui';

enum MoodType {
  amazing('😁', 'Amazing', Color(0xFF4CAF50)),
  happy('😊', 'Happy', Color(0xFFFFC107)),
  neutral('😐', 'Neutral', Color(0xFF9E9E9E)),
  sad('😔', 'Sad', Color(0xFF2196F3)),
  angry('😡', 'Angry', Color(0xFFF44336));

  const MoodType(this.emoji, this.label, this.color);
  final String emoji;
  final String label;
  final Color color;

  static MoodType fromLabel(String label) {
    return values.firstWhere(
      (m) => m.label.toLowerCase() == label.toLowerCase(),
      orElse: () => MoodType.neutral, // Default to neutral if no match found
    );
  }

  static MoodType fromEmoji(String emoji) {
    return values.firstWhere(
      (m) => m.emoji == emoji,
      orElse: () => MoodType.neutral, // Default to neutral if no match found
    );
  }
}
