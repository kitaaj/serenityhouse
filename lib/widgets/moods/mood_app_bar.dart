import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoodSliverAppBar extends StatelessWidget {
  final BuildContext context;
  const MoodSliverAppBar({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: const Icon(Icons.calendar_month),
      pinned: true,
      expandedHeight: 150,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
            ),
          ),
        ),
        title: Text(DateFormat('MMMM y').format(DateTime.now())),
      ),
    );
  }
}
