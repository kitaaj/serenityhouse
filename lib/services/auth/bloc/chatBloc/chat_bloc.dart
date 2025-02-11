import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mental_health_support/models/chat.dart';
import 'package:mental_health_support/models/message.dart';
import 'package:mental_health_support/services/aiService/ai_service.dart';
import 'package:mental_health_support/services/auth/auth_service.dart';
import 'package:mental_health_support/services/auth/bloc/chatBloc/chat_event.dart';
import 'package:mental_health_support/services/auth/bloc/chatBloc/chat_state.dart';
import 'package:mental_health_support/services/local/repository/chat_repository.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final GeminiService _geminiService;
  final AuthService _auth;
  StreamSubscription<List<Message>>? _messagesSubscription;
  StreamSubscription<List<Chat>>? _chatsSubscription;
  String? _currentChatId;

  ChatBloc({
    required GeminiService geminiService,
    required AuthService authService,
    required ChatRepository chatRepository,
    FirebaseAuth? auth,
  }) : _chatRepository = chatRepository,
       _geminiService = geminiService,
       _auth = authService,
       super(ChatListInitial()) {
    // Initialize with ChatListInitial
    on<InitChatEvent>(_onInit);
    on<SendMessageEvent>(_onSendMessage);
    on<LoadChatEvent>(_onLoadChat);
    on<NewChatEvent>(_onNewChat);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<ChatsUpdated>(_onChatsUpdated);
  }

  /// **Handles Initialization of Chat Sessions (Chat List)**
  Future<void> _onInit(InitChatEvent event, Emitter<ChatState> emit) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(ChatListError(errorMessage: 'User not authenticated.'));
      return;
    }

    emit(ChatListLoading());

    try {
      // Subscribe to real-time chat updates
      _chatsSubscription = _chatRepository.watchAllChats(user.id).listen((
        chats,
      ) {
        add(ChatsUpdated(chats));
      });
    } catch (e) {
      emit(ChatListError(errorMessage: e.toString()));
    }
  }

  /// **Handles Creating a New Chat Session**
  Future<void> _onNewChat(NewChatEvent event, Emitter<ChatState> emit) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(ChatListError(errorMessage: 'User not authenticated.'));
      return;
    }

    emit(ChatListLoading());

    try {
      final newChat = await _chatRepository.createNewChat(user.id);
      emit(
        ChatListReady(
          sessions: [
            newChat,
            ...(state is ChatListReady
                ? (state as ChatListReady).sessions
                : []),
          ],
        ),
      );
    } catch (e) {
      emit(ChatListError(errorMessage: e.toString()));
    }
  }

  /// **Handles Receiving Updated Chats**
  void _onChatsUpdated(ChatsUpdated event, Emitter<ChatState> emit) {
    emit(ChatListReady(sessions: event.chats));
  }

  /// **Handles Loading an Individual Chat's Messages**
  Future<void> _onLoadChat(LoadChatEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());

    _currentChatId = event.chatId;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(ChatError(errorMessage: 'User not authenticated.'));
        return;
      }

      // Fetch messages (from cache or Firestore)
      final messages = await _chatRepository.getMessages(user.id, event.chatId);

      emit(ChatReadyState(messages: messages, chatId: event.chatId));

      // Listen to real-time message updates
      _messagesSubscription?.cancel();
      _messagesSubscription = _chatRepository
          .watchMessages(user.id, event.chatId)
          .listen((messages) {
            add(MessagesUpdated(messages));
          });
    } catch (e) {
      debugPrint(e.toString());
      emit(ChatError(errorMessage: e.toString()));
    }
  }

  /// **Handles Sending a Message in an Individual Chat**
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentChatId == null) {
      emit(ChatError(errorMessage: 'No active chat session.'));
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      emit(ChatError(errorMessage: 'User not authenticated.'));
      return;
    }

    try {
      // Send user's message
      await _chatRepository.sendMessage(
        user.id,
        _currentChatId!,
        event.content,
        true,
      );

      // Emit typing state to show indicator
      if (state is ChatReadyState) {
        final currentState = state as ChatReadyState;
        emit(
          ChatTypingState(
            messages: currentState.messages,
            chatId: _currentChatId!,
          ),
        );
      }

      // Get AI response
      final aiResponse = await _geminiService.getAIResponse(
        event.content,
        (state is ChatTypingState) ? (state as ChatTypingState).messages : [],
      );

      // Send AI response
      await _chatRepository.sendMessage(
        user.id,
        _currentChatId!,
        aiResponse,
        false,
      );
    } catch (e) {
      emit(ChatError(errorMessage: e.toString()));
    }
  }

  /// **Handles Messages Updated via Stream Subscription**
  void _onMessagesUpdated(MessagesUpdated event, Emitter<ChatState> emit) {
    if (state is ChatReadyState) {
      final currentState = state as ChatReadyState;
      emit(currentState.copyWith(messages: event.messages));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _chatsSubscription?.cancel(); // Ensure chats subscription is also canceled
    return super.close();
  }
}
