import 'package:mental_health_support/models/message.dart';

abstract class ChatSessionState {}

class ChatSessionInitial extends ChatSessionState {}

class ChatSessionLoading extends ChatSessionState {}

class ChatSessionReady extends ChatSessionState {
  final List<Message> messages;
  final String chatId;

  ChatSessionReady({
    required this.messages,
    required this.chatId,
  });

  ChatSessionReady copyWith({List<Message>? messages, String? chatId}) {
    return ChatSessionReady(
      messages: messages ?? this.messages,
      chatId: chatId ?? this.chatId,
    );
  }
}

class ChatSessionError extends ChatSessionState {
  final String errorMessage;

  ChatSessionError({required this.errorMessage});
}
