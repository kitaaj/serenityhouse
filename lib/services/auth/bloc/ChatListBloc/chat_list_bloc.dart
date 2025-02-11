import 'dart:async';
import 'chat_list_event.dart';
import 'chat_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/models/chat.dart';
import 'package:mental_health_support/services/auth/auth_service.dart';
import 'package:mental_health_support/services/local/repository/chat_repository.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository _chatRepository;
  final AuthService _auth;
  StreamSubscription<List<Chat>>? _chatsSubscription;

  ChatListBloc({
    required AuthService authService,
    required ChatRepository chatRepository,
  }) : _auth = authService,
       _chatRepository = chatRepository,
       super(ChatListInitial()) {
    on<InitChatListEvent>(_onInit);
    on<NewChatListEvent>(_onNewChat);
    on<ChatsListUpdated>(_onChatsUpdated);
  }

  Future<void> _onInit(
    InitChatListEvent event,
    Emitter<ChatListState> emit,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(ChatListError(errorMessage: 'User not authenticated.'));
      return;
    }

    emit(ChatListLoading());

    try {
      _chatsSubscription = _chatRepository.watchAllChats(user.id).listen((
        chats,
      ) {
        add(ChatsListUpdated(chats));
      });
    } catch (e) {
      emit(ChatListError(errorMessage: e.toString()));
    }
  }

  Future<void> _onNewChat(
    NewChatListEvent event,
    Emitter<ChatListState> emit,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(ChatListError(errorMessage: 'User not authenticated.'));
      return;
    }

    try {
      final newChat = await _chatRepository.createNewChat(user.id);
      if (state is ChatListReady) {
        final updatedChats = List<Chat>.from((state as ChatListReady).chats)
          ..insert(0, newChat);
        emit(ChatListReady(updatedChats));
      }
    } catch (e) {
      emit(ChatListError(errorMessage: e.toString()));
    }
  }

  void _onChatsUpdated(ChatsListUpdated event, Emitter<ChatListState> emit) {
    emit(ChatListReady(event.chats));
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}
