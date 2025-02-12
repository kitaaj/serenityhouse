import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mental_health_support/helpers/helper_functions/is_same_day.dart';
import 'package:mental_health_support/main.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_state.dart';
import 'package:mental_health_support/widgets/moods/mood_list_tile.dart';

void showDailyMood(BuildContext context, DateTime date) {
  final bloc = context.read<MoodBloc>();
  final moods =
      bloc.state is MoodLoadedState
          ? (bloc.state as MoodLoadedState).moods
              .where((m) => isSameDay(m.date, date))
              .toList()
          : [];

  'Number of moods on ${DateFormat('EEEE, MMM d').format(date)}: ${moods.length}'
      .log();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return BlocBuilder<MoodBloc, MoodState>(
        builder: (context, state) {
          final bloc = context.read<MoodBloc>();
          final moods =
              bloc.state is MoodLoadedState
                  ? (bloc.state as MoodLoadedState).moods
                      .where((m) => isSameDay(m.date, date))
                      .toList()
                  : [];
          state.log();
          'Number of moods from the BlocBuilder on ${DateFormat('EEEE, MMM d').format(date)}: ${moods.length}'
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
                    // Title
                    Text(
                      DateFormat('EEEE, MMM d').format(date),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          moods.isEmpty
                              ? const Center(child: Text('No mood entries'))
                              : ListView.builder(
                                controller: scrollController,
                                itemCount: moods.length,
                                itemBuilder:
                                    (context, index) => Builder(
                                      builder:
                                          (context) =>
                                              MoodListTile(mood: moods[index]),
                                    ),
                              ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, bottom: 12.0),
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
              },
            ),
          );
        },
      );
    },
  );
}
