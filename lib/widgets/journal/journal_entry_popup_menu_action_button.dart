import 'package:flutter/material.dart';
import 'package:mental_health_support/enums/menu_action.dart';
import 'package:mental_health_support/helpers/screen_routes.dart';
import 'package:mental_health_support/services/cloud/cloud_journal_entry.dart';
import 'package:mental_health_support/services/cloud/firebase_cloud_storage.dart';
import 'package:mental_health_support/utilities/dialogs/delete_dialog.dart';

class JournalEntryCustomPopupMenuButton extends StatefulWidget {
  final JournalEntry entry; // Add this parameter

  const JournalEntryCustomPopupMenuButton({
    super.key,
    required this.entry, // Require the journal entry
  });

  @override
  State<JournalEntryCustomPopupMenuButton> createState() =>
      _JournalEntryCustomPopupMenuButtonState();
}

class _JournalEntryCustomPopupMenuButtonState
    extends State<JournalEntryCustomPopupMenuButton> {
  late final FirebaseCloudStorage _journalService;

  @override
  void initState() {
    _journalService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<JournalMenuAction>(
      tooltip: 'Options',
      onSelected: (value) async {
        switch (value) {
          case JournalMenuAction.edit:
            Navigator.of(context).pushNamed(
              editJournalRoute,
              arguments: widget.entry, // Pass the entry to edit screen
            );
            break;
          case JournalMenuAction.delete:
            final shouldDelete = await showDeleteDialog(context);
            if (shouldDelete) {
              await _journalService.deleteJournalEntry(
                documentId: widget.entry.documentId, // Use widget.entry
              );
              // Optionally notify the parent widget about deletion
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Journal entry deleted')),
              );
            }
            break;
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem<JournalMenuAction>(
            value: JournalMenuAction.edit,
            child: ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
          ),
          PopupMenuItem<JournalMenuAction>(
            value: JournalMenuAction.delete,
            child: ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ];
      },
    );
  }
}
