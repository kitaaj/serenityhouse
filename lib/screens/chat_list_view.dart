import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/models/chat.dart';
import 'package:mental_health_support/helpers/screen_routes.dart';
import 'package:mental_health_support/services/auth/bloc/ChatListBloc/chat_list_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/ChatListBloc/chat_list_event.dart';
import 'package:mental_health_support/services/auth/bloc/ChatListBloc/chat_list_state.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  @override
  void initState() {
    super.initState();
    _initializeChats();
  }

  void _initializeChats() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatListBloc>().add(InitChatListEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewChat(context),
        tooltip: 'Start new chat',
        child: const Icon(Icons.android),
      ),
      body: BlocConsumer<ChatListBloc, ChatListState>(
        listener: (context, state) {
          if (state is ChatListError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        builder: (context, state) {
          if (state is ChatListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.errorMessage}'),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed:
                        () => context.read<ChatListBloc>().add(
                          InitChatListEvent(),
                        ),
                    icon: Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ChatListReady) {
            return _buildChatList(state.chats, context);
          }

          return const Center(child: Text('No chat sessions available'));
        },
      ),
    );
  }

  Widget _buildChatList(List<Chat> chats, context) {
    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No chats yet. Start a new conversation with our AI assistant!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () {
                _createNewChat(context);
              },
              label: Text('Start new chat'),
              icon: Icon(Icons.chat),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsetsDirectional.only(top: 8.0),
      itemCount: chats.length,
      itemBuilder: (context, index) => _ChatListItem(session: chats[index]),
    );
  }

  Future<void> _createNewChat(BuildContext context) async {
    context.read<ChatListBloc>().add(NewChatListEvent());
  }
}

class _ChatListItem extends StatelessWidget {
  final Chat session;

  const _ChatListItem({required this.session});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _ChatAvatar(session: session),
      title: Text(
        session.title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        session.latestMessage ?? 'No messages yet',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _ChatTrailingInfo(session: session),
      onTap: () => _openChat(context),
    );
  }

  void _openChat(BuildContext context) {
    Navigator.pushNamed(context, chatRoute, arguments: session.chatId);
  }
}

class _ChatAvatar extends StatelessWidget {
  final Chat session;

  const _ChatAvatar({required this.session});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        session.title.isNotEmpty
            ? session.title.substring(0, 1).toUpperCase()
            : '?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _ChatTrailingInfo extends StatelessWidget {
  final Chat session;

  const _ChatTrailingInfo({required this.session});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          DateFormat('hh:mm a').format(session.updatedAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (session.unreadCount > 0)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              session.unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
