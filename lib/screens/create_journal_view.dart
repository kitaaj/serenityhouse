// create_journal_view.dart
import 'package:flutter/material.dart';
import 'package:mental_health_support/services/auth/auth_service.dart';
import 'package:mental_health_support/services/cloud/firebase_cloud_storage.dart';

class CreateJournalView extends StatefulWidget {
  const CreateJournalView({super.key});

  @override
  State<CreateJournalView> createState() => _CreateJournalViewState();
}

class _CreateJournalViewState extends State<CreateJournalView> {
  late final FirebaseCloudStorage _journalsService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _journalsService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  Future<void> _createJournal(BuildContext context) async {
    final text = _textController.text;
    if (text.isEmpty) return;

    final currentUser = AuthService.firebase().currentUser!;
    await _journalsService.createJournalEntry(
      userId: currentUser.id,
      content: text,
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
        title: const Text('New Journal Entry'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _createJournal(context);
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
            hintText: 'Start typing your thoughts...',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
