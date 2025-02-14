import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/helpers/logger.dart';
import 'package:mental_health_support/widgets/moods/mood_list_tile.dart';
import 'package:mental_health_support/helpers/helper_functions/is_same_day.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_state.dart';

void showDailyMood(BuildContext context, DateTime date) {

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          initialChildSize: 0.6,
          builder: (context, scrollController) {
            return BlocBuilder<MoodBloc, MoodState>(
              builder: (context, state) {
                if (state is MoodLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MoodLoadedState) {
                  final moods =
                      state.moods
                          .where((m) => isSameDay(m.date, date))
                          .toList();

                  'Number of moods on ${DateFormat('EEEE, MMM d').format(date)}: ${moods.length}'
                      .log();

                  return Column(
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(top: 12, bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMM d').format(date),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child:
                            moods.isEmpty
                                ? const Center(
                                  child: Text(
                                    'No mood entries',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                                : ListView.builder(
                                  controller: scrollController,
                                  itemCount: moods.length,
                                  itemBuilder: (context, index) {
                                    final mood = moods[index];
                                    return MoodListTile(mood: mood);
                                  },
                                ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 16.0,
                          bottom: 12.0,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (state is MoodErrorState) {
                  return Center(
                    child: Text(
                      'Failed to load moods: ${state.message}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return const Center(child: Text('No mood entries'));
                }
              },
            );
          },
        ),
      );
    },
  );
}
