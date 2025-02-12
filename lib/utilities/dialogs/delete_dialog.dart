import 'package:flutter/material.dart';
import 'package:mental_health_support/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context, [String? content]) {
  final itemName = content ?? 'journal';
  return showGenericDialog(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this $itemName?',
    optionsBuilder: () => {'Cancel': false, 'Yes': true},
  ).then((value) => value ?? false);
}
