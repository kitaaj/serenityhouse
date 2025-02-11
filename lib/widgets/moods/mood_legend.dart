import 'package:flutter/material.dart';
import 'package:mental_health_support/enums/mood_type.dart';

class MoodLegend extends StatelessWidget {
  const MoodLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: MoodType.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final mood = MoodType.values[index];
              return _MoodLegendItem(mood: mood);
            },
          ),
        ),
      ),
    );
  }
}

class _MoodLegendItem extends StatelessWidget {
  final MoodType mood;

  const _MoodLegendItem({required this.mood});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: mood.color.withAlpha(70),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          mood.label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: mood.color),
        ),
      ],
    );
  }
}
