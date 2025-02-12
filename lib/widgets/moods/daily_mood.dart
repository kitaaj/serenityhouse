import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/models/mood.dart';
import 'package:mental_health_support/helpers/logger.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_event.dart';
import 'package:mental_health_support/widgets/moods/mood_list_tile.dart';
import 'package:mental_health_support/helpers/helper_functions/is_same_day.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_state.dart';

void showDailyMood(BuildContext context, DateTime date) {
  final bloc = context.read<MoodBloc>();

  bloc.add(LoadMoodsEvent());

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return BlocBuilder<MoodBloc, MoodState>(
        builder: (context, state) {
          List<MoodEntry> moodsToShow = [];
          bool isLoading = false;

          if (state is MoodLoadingState) {
            // Use previous moods if available.
            moodsToShow =
                state.previousMoods
                    ?.where((m) => isSameDay(m.date, date))
                    .toList() ??
                [];
            isLoading = true;
          } else if (state is MoodLoadedState) {
            moodsToShow =
                state.moods.where((m) => isSameDay(m.date, date)).toList();
          }

          'Number of moods from BlocBuilder on ${DateFormat('EEEE, MMM d').format(date)}: ${moodsToShow.length}'
              .log();

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
                Widget content;
                if (isLoading && moodsToShow.isEmpty) {
                  content = const Center(child: CircularProgressIndicator());
                } else if (moodsToShow.isEmpty) {
                  content = const Center(child: Text('No mood entries'));
                } else {
                  content = ListView.builder(
                    controller: scrollController,
                    itemCount: moodsToShow.length,
                    itemBuilder:
                        (context, index) =>
                            MoodListTile(mood: moodsToShow[index]),
                  );
                }

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
                    Expanded(child: content),
                    if (isLoading && moodsToShow.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                );
              },
            ),
          );
        },
      );
    },
  );
}
