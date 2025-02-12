import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/enums/mood_type.dart';
import 'package:mental_health_support/models/mood.dart';
import 'package:mental_health_support/services/auth/auth_service.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_event.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_state.dart';
import 'package:mental_health_support/widgets/moods/mood_button.dart';

class MoodPicker extends StatelessWidget {
  const MoodPicker({super.key});

  static void showMoodPicker(BuildContext context) {
    final user = AuthService.firebase().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => _MoodPickerContent(userId: user.id),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MoodBloc, MoodState>(
      listener: (context, state) {
        if (state is MoodErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: IconButton(
        icon: const Icon(Icons.mood),
        onPressed: () => showMoodPicker(context),
      ),
    );
  }

  
}

class _MoodPickerContent extends StatelessWidget {
  final String userId;

  const _MoodPickerContent({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            'How are you feeling today?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 1,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            padding: const EdgeInsets.all(16),
            children:
                MoodType.values
                    .map(
                      (mood) => MoodButton(
                        mood: mood,
                        onPressed: () => _addMood(context, mood),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _addMood(BuildContext context, MoodType mood) {
    context.read<MoodBloc>().add(
      AddMoodEvent(
        MoodEntry(
          id: '',
          userId: userId,
          date: DateTime.now(),
          label: mood.label,
          notes: '',
          tags: [],
        ),
      ),
    );
    Navigator.pop(context);
  }
}


