import 'package:mental_health_support/models/chat.dart';

abstract class ChatListEvent {}

class InitChatListEvent extends ChatListEvent {}

class NewChatListEvent extends ChatListEvent {}

class ChatsListUpdated extends ChatListEvent {
  final List<Chat> chats;

  ChatsListUpdated(this.chats);
}

// In chat_list_event.dart
class ResetUnreadCountEvent extends ChatListEvent {
  final String chatId;

  ResetUnreadCountEvent(this.chatId);

  List<Object?> get props => [chatId];
}
