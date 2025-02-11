// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
// import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_event.dart';

// void _showDailyMood(BuildContext context, DateTime date) {
//   final moods = context.read<MoodBloc>().getMoodsForDate(date);
  
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Text(DateFormat('EEEE, MMM d').format(date)),
//       content: Column(
//         children: [
//           if (moods.isEmpty)
//             const Text('No mood entries')
//           else
//             ...moods.map((mood) => ListTile(
//               leading: Text(mood.emoji),
//               title: Text(mood.label),
//               trailing: IconButton(
//                 icon: const Icon(Icons.delete),
//                 onPressed: () => context.read<MoodBloc>().add(
//                   DeleteMoodEvent(mood.documentId),
//                 ),
//               ),
//             )),
//         ],
//       ),
//     ),
//   );
// }