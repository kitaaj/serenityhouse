// chat_event.dart

import 'package:mental_health_support/models/chat.dart';
import 'package:mental_health_support/models/message.dart';

abstract class ChatEvent {}

// Events for Chat List
class InitChatEvent extends ChatEvent {}

class NewChatEvent extends ChatEvent {}

// Events for Individual Chats
class LoadChatEvent extends ChatEvent {
  final String chatId;

  LoadChatEvent(this.chatId);
}

class SendMessageEvent extends ChatEvent {
  final String content;
  final bool isUser;

  SendMessageEvent(this.content, this.isUser);
}

// Event for Messages Update
class MessagesUpdated extends ChatEvent {
  final List<Message> messages;

  MessagesUpdated(this.messages);
}

// **Newly Added Event for Chats Update**
class ChatsUpdated extends ChatEvent {
  final List<Chat> chats;

  ChatsUpdated(this.chats);
}
