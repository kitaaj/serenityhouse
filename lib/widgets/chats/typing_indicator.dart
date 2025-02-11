import 'package:flutter/material.dart';
import 'package:mental_health_support/widgets/chats/animated_dot.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                AnimatedDot(delay: 0),
                AnimatedDot(delay: 200),
                AnimatedDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
