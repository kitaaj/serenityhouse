import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/ChatListBloc/chat_list_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/ChatListBloc/chat_list_event.dart';

class RefreshIcon extends StatelessWidget {
  const RefreshIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () => context.read<ChatListBloc>().add(InitChatListEvent()),
      tooltip: 'Refesh chats',
    );
  }
}
