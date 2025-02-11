// chat_state.dart


import 'package:mental_health_support/models/chat.dart';
import 'package:mental_health_support/models/message.dart';

abstract class ChatState {}

// States for Chat List (Sessions)
class ChatListInitial extends ChatState {}

class ChatListLoading extends ChatState {}

class ChatListError extends ChatState {
  final String errorMessage; // Non-nullable

  ChatListError({required this.errorMessage});
}

class ChatListReady extends ChatState {
  final List<Chat> sessions;

  ChatListReady({required this.sessions});
}

// States for Individual Chat Messages
class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatError extends ChatState {
  final String errorMessage; // Non-nullable

  ChatError({required this.errorMessage});
}

class ChatTypingState extends ChatState {
  final List<Message> messages;
  final String chatId;

  ChatTypingState({required this.messages, required this.chatId});
}

class ChatReadyState extends ChatState {
  // Renamed for clarity
  final List<Message> messages;
  final String chatId;

  ChatReadyState({required this.messages, required this.chatId});

  ChatReadyState copyWith({List<Message>? messages, String? chatId}) {
    return ChatReadyState(
      messages: messages ?? this.messages,
      chatId: chatId ?? this.chatId,
    );
  }
}
