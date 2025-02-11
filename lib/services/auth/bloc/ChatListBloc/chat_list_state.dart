import 'package:mental_health_support/models/chat.dart';

abstract class ChatListState {}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListReady extends ChatListState {
  final List<Chat> chats;

  ChatListReady(this.chats);
}

class ChatListError extends ChatListState {
  final String errorMessage;

  ChatListError({required this.errorMessage});
}
