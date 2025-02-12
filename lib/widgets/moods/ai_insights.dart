import 'package:flutter/material.dart';
import 'package:mental_health_support/helpers/helper_functions/generate_insights.dart';
import 'package:mental_health_support/models/mood.dart';

class AIInsightsCard extends StatelessWidget {
  final List<MoodEntry> moods;

  const AIInsightsCard({super.key, required this.moods});

  @override
  Widget build(BuildContext context) {
    final insights = generateInsights(moods);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insights,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your Insights',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...insights.map(
                (insight) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8),
                      const SizedBox(width: 12),
                      Expanded(child: Text(insight)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
