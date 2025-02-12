import 'package:flutter/material.dart';
import 'package:mental_health_support/enums/mood_type.dart';

class MoodButton extends StatelessWidget {
  final MoodType mood;
  final VoidCallback onPressed;

  const MoodButton({super.key, required this.mood, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: mood.color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: mood.color.withAlpha(50)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              mood.label,
              style: TextStyle(
                color: mood.color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}