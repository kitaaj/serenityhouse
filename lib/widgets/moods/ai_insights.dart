import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_state.dart';

class AIInsightsCard extends StatelessWidget {
  const AIInsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoodBloc, MoodState>(
      builder: (context, state) {
        if (state is! MoodLoadedState) return const SizedBox.shrink();

        try {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(Icons.insights),
                      title: Text(
                        'Personalized Insights',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),

                    ...(state.generatedInsights ?? ['Loading insights...']).map(
                      (insight) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('• $insight'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } catch (e) {
          return ErrorWidget('Failed to load insights: $e');
        }
      },
    );
  }
}
