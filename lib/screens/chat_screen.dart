import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/ChatSessionBloc/chat_session_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/ChatSessionBloc/chat_session_event.dart';
import 'package:mental_health_support/services/auth/bloc/ChatSessionBloc/chat_session_state.dart';
import 'package:mental_health_support/widgets/chats/chat_input_widget.dart';
import 'package:mental_health_support/widgets/chats/message_build_list.dart';

class ChatScreen extends StatefulWidget {
  final String sessionId;
  const ChatScreen({required this.sessionId, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  late final ChatSessionBloc _chatSessionBloc;

  @override
  void initState() {
    super.initState();
    _chatSessionBloc = context.read<ChatSessionBloc>();
    _chatSessionBloc.add(LoadChatSessionEvent(widget.sessionId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom(context) {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent
            +MediaQuery.of(context).viewInsets.bottom, // Add keyboard height
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Serenity House'),
          actions: [
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.search),
              onPressed: () {
                // Handle search functionality here
              },
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: BlocConsumer<ChatSessionBloc, ChatSessionState>(
                  listener: (context, state) {
                    if (state is ChatSessionReady) {
                      _scrollToBottom(
                        context,
                      ); // Trigger scroll when messages update
                    }
                    if (state is ChatSessionError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is ChatSessionLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChatSessionReady) {
                      return MessageBuildList(
                        messages: state.messages,
                        scrollController: _scrollController,
                      );
                    } else if (state is ChatSessionError) {
                      return Center(child: Text(state.errorMessage));
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              ChatInputWidget(
                onSendMessage: (message, isUser) {
                  _chatSessionBloc.add(
                    SendMessageSessionEvent(message, isUser),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
