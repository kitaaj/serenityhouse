import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/models/mood.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_event.dart';
import 'package:mental_health_support/utilities/dialogs/delete_dialog.dart';

class MoodListTile extends StatefulWidget {
  final MoodEntry mood;

  const MoodListTile({super.key, required this.mood});

  @override
  State<MoodListTile> createState() => _MoodListTileState();
}

class _MoodListTileState extends State<MoodListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: () async {
        final bool shoulDelete = await showDeleteDialog(context, 'mood');
        if (!context.mounted) return;
        if (shoulDelete) {
          context.read<MoodBloc>().add(DeleteMoodEvent(widget.mood.id));
        }
      },
      dense: true,
      leading: CircleAvatar(
        backgroundColor: widget.mood.color.withAlpha(75),
        child: Text(widget.mood.emoji, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(widget.mood.label),
      subtitle:
          widget.mood.notes != null && widget.mood.notes!.isNotEmpty
              ? Text(widget.mood.notes!)
              : null,
      trailing: IconButton(
        icon: const Icon(Icons.edit_note),
        onPressed: () {
          _showEditNotesDialog(context, widget.mood);
        },
      ),
    );
  }

  void _showEditNotesDialog(BuildContext context, MoodEntry mood) {
    final TextEditingController notesController = TextEditingController(
      text: mood.notes,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add/Edit Notes'),
          content: TextField(
            controller: notesController,
            decoration: const InputDecoration(
              hintText: 'Enter your notes here',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedNotes = notesController.text.trim();
                // Dispatch an UpdateMoodEvent with the updated notes
                context.read<MoodBloc>().add(
                  UpdateMoodEvent(
                    mood.copyWith(
                      notes: updatedNotes.isEmpty ? null : updatedNotes,
                    ),
                  ),
                );
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
