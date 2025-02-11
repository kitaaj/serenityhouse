// edit_journal_view.dart
import 'package:flutter/material.dart';
import 'package:mental_health_support/services/cloud/cloud_journal_entry.dart';
import 'package:mental_health_support/services/cloud/firebase_cloud_storage.dart';
import 'package:mental_health_support/utilities/generics/get_arguments.dart';

class EditJournalView extends StatefulWidget {
  const EditJournalView({super.key});

  @override
  State<EditJournalView> createState() => _EditJournalViewState();
}

class _EditJournalViewState extends State<EditJournalView> {
  late final FirebaseCloudStorage _journalsService;
  late final TextEditingController _textController;
  late final JournalEntry _journal;

  @override
  void initState() {
    super.initState();
    _journalsService = FirebaseCloudStorage();
    _textController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _journal = context.getArgument<JournalEntry>()!;
    _textController.text = _journal.content;
  }

  Future<void> _updateJournal(BuildContext context) async {
    final text = _textController.text;
    if (text.isEmpty) return;

    await _journalsService.updateJournalEntry(
      documentId: _journal.documentId,
      content: text,
      // userId: _journal.userId,
    );
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Journal Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _updateJournal(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textController,
          autofocus: true,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Edit your journal entry...',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
