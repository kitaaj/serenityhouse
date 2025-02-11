import 'package:flutter/material.dart';
import 'package:mental_health_support/services/auth/auth_service.dart';
import 'package:mental_health_support/services/cloud/cloud_journal_entry.dart';
import 'package:mental_health_support/services/cloud/firebase_cloud_storage.dart';
import 'package:mental_health_support/utilities/generics/get_arguments.dart';

class CreateUpdateJournalView extends StatefulWidget {
  const CreateUpdateJournalView({super.key});

  @override
  State<CreateUpdateJournalView> createState() =>
      _CreateUpdateJournalViewState();
}

class _CreateUpdateJournalViewState extends State<CreateUpdateJournalView> {
  JournalEntry? _journal;
  late final FirebaseCloudStorage _journalsService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _journalsService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final journal = _journal;
    if (journal == null) {
      return;
    }
    final text = _textController.text;
    await _journalsService.updateJournalEntry(
      documentId: journal.documentId,
      content: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<JournalEntry> createOrGetExistingJournal(BuildContext context) async {
    final widgetJournal = context.getArgument<JournalEntry>();

    if (widgetJournal != null) {
      _journal = widgetJournal;
      _textController.text = widgetJournal.content;
      return widgetJournal;
    }

    final existingJournal = _journal;
    if (existingJournal != null) {
      return existingJournal;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newJournal = await _journalsService.createJournalEntry(
      userId: userId,
      content: ''
    );
    _journal = newJournal;
    return newJournal;
  }

  void _deleteJournalIfContentIsEmpty() {
    final journal = _journal;
    if (_textController.text.isEmpty && journal != null) {
      _journalsService.deleteJournalEntry(documentId: journal.documentId);
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final journal = _journal;
    final text = _textController.text;
    if (journal != null && text.isNotEmpty) {
      await _journalsService.updateJournalEntry(
        documentId: journal.documentId,
        content: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteJournalIfContentIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal entry'), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: createOrGetExistingJournal(context),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _setupTextControllerListener();
                return TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  autofocus: true,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Start typing your note...',
                    border: InputBorder.none,
                  ),
                );
              default:
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
            }
          },
        ),
      ),
    );
  }
}
