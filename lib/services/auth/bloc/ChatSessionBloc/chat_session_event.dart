import 'package:mental_health_support/models/message.dart';

abstract class ChatSessionEvent {}

class LoadChatSessionEvent extends ChatSessionEvent {
  final String chatId;

  LoadChatSessionEvent(this.chatId);
}

class SendMessageSessionEvent extends ChatSessionEvent {
  final String message;
  final bool isUser;

  SendMessageSessionEvent(this.message, this.isUser);
}

class MessagesSessionUpdated extends ChatSessionEvent {
  final List<Message> messages;

  MessagesSessionUpdated(this.messages);
}