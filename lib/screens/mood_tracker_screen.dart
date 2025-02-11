import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/services/local/repository/achievement_repository.dart';
import 'package:mental_health_support/utilities/dependency_injection.dart';
import 'package:mental_health_support/widgets/moods/mood_picker.dart';
import 'package:mental_health_support/widgets/moods/main_contents.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
import 'package:mental_health_support/services/cloud/firebase_cloud_storage.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_state.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_event.dart';
import 'package:mental_health_support/services/local/repository/mood_repository.dart';
import 'package:mental_health_support/services/auth/bloc/achievementBloc/achievement_bloc.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => MoodBloc(
                getIt<
                  FirebaseCloudStorage
                >(), // Retrieve FirebaseCloudStorage from GetIt
                getIt<
                  HiveMoodRepository
                >(), // Retrieve HiveMoodRepository from GetIt
              )..add(LoadMoodsEvent()),
        ),
        BlocProvider(
          create:
              (context) => AchievementBloc(
                context.read<MoodBloc>(),
                getIt<AchievementRepository>(),
              ),
        ),
      ],
      child: Scaffold(
        body: BlocConsumer<MoodBloc, MoodState>(
          listener: (context, state) {
            if (state is MoodErrorState) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is MoodLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MoodErrorState) {
              return ErrorWidget(state.message);
            }
            if (state is MoodLoadedState) {
              return MainContent(state: state);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => MoodPicker.showMoodPicker(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
