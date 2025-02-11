import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/models/mood.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_state.dart';

class CalendarDay extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPressed;

  const CalendarDay({super.key, required this.date, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MoodBloc, MoodState, List<MoodEntry>?>(
      selector:
          (state) =>
              state is MoodLoadedState
                  ? state.moodMap[DateTime(date.year, date.month, date.day)]
                  : null,
      builder: (context, moods) {
        final hasMood = moods != null && moods.isNotEmpty;
        final primaryMood = hasMood ? moods.first : null;

        return GestureDetector(
          onTap: onPressed,
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color:
                  hasMood
                      ? primaryMood!.color.withAlpha(20)
                      : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    hasMood
                        ? primaryMood!.color.withAlpha(50)
                        : Colors.grey.withAlpha(30),
                width: hasMood ? 1.5 : 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color:
                          hasMood
                              ? primaryMood!.color
                              : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hasMood)
                    Text(
                      primaryMood!.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
