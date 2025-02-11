import 'package:flutter/material.dart';
import 'package:mental_health_support/helpers/screen_routes.dart';
import 'package:mental_health_support/screens/journal_List_view.dart';
import 'package:mental_health_support/services/auth/auth_service.dart';
import 'package:mental_health_support/services/cloud/cloud_journal_entry.dart';
import 'package:mental_health_support/services/cloud/firebase_cloud_storage.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late final FirebaseCloudStorage _journalService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _journalService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Iterable<JournalEntry>>(
        stream: _journalService.allJournalEntries(userId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allEntries = snapshot.data as Iterable<JournalEntry>;
                return JournalListView(
                  entries: allEntries,
                  onTap: (entry) {
                    Navigator.of(
                      context,
                    ).pushNamed(editJournalRoute, arguments: entry);
                  },
                  onDeleteJournal: (entry) async {
                    await _journalService.deleteJournalEntry(
                      documentId: entry.documentId,
                    );
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'journalFAB',
        onPressed: () {
          Navigator.of(context).pushNamed(createJournalRoute);
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
