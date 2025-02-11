// ignore: file_names
import 'package:flutter/material.dart';
import 'package:mental_health_support/services/cloud/cloud_journal_entry.dart';
import 'package:mental_health_support/widgets/journal/journal_entry_popup_menu_action_button.dart';

typedef NoteCallBack = void Function(JournalEntry journal);

class JournalListView extends StatelessWidget {
  final Iterable<JournalEntry> entries;
  final NoteCallBack onDeleteJournal;
  final NoteCallBack onTap;

  const JournalListView({
    super.key,
    required this.entries,
    required this.onTap,
    required this.onDeleteJournal,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(thickness: 0.25),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final journal = entries.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(journal); // Handle tap event
          },
          title: Text(
            journal.content,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          horizontalTitleGap: 0, // Reduce space between leading/title
          minVerticalPadding: 0,
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 15,
            ), // Limit trailing width
            child: JournalEntryCustomPopupMenuButton(entry: journal),
          ),
        );
      },
    );
  }
}
