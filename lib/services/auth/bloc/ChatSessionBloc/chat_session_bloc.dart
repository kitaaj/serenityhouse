import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/models/message.dart';
import 'package:mental_health_support/services/auth/auth_service.dart';
import 'package:mental_health_support/services/local/repository/chat_repository.dart';
import 'package:mental_health_support/services/aiService/ai_service.dart';
import 'chat_session_event.dart';
import 'chat_session_state.dart';

class ChatSessionBloc extends Bloc<ChatSessionEvent, ChatSessionState> {
  final ChatRepository _chatRepository;
  final GeminiService _geminiService;
  final AuthService _auth;
  StreamSubscription<List<Message>>? _messagesSubscription;
  String? _currentChatId;

  ChatSessionBloc({
    required GeminiService geminiService,
    required AuthService authService,
    required ChatRepository chatRepository,
  }) : _geminiService = geminiService,
       _auth = authService,
       _chatRepository = chatRepository,
       super(ChatSessionInitial()) {
    on<LoadChatSessionEvent>(_onLoadChat);
    on<SendMessageSessionEvent>(_onSendMessage);
    on<MessagesSessionUpdated>(_onMessagesUpdated);
  }

  Future<void> _onLoadChat(
    LoadChatSessionEvent event,
    Emitter<ChatSessionState> emit,
  ) async {
    emit(ChatSessionLoading());

    _currentChatId = event.chatId;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(ChatSessionError(errorMessage: 'User not authenticated.'));
        return;
      }

      // Reset unread count when chat is opened
      await _chatRepository.resetUnreadCount(
        userId: user.id,
        chatId: event.chatId,
      );

      // Fetch messages (from cache or Firestore)
      final messages = await _chatRepository.getMessages(user.id, event.chatId);

      emit(ChatSessionReady(messages: messages, chatId: event.chatId));

      // Listen to real-time message updates
      _messagesSubscription?.cancel();
      _messagesSubscription = _chatRepository
          .watchMessages(user.id, event.chatId)
          .listen((messages) {
            add(MessagesSessionUpdated(messages));
          });
    } catch (e) {
      emit(ChatSessionError(errorMessage: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessageSessionEvent event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (_currentChatId == null) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      if (state is ChatSessionReady) {
        final currentState = state as ChatSessionReady;

        // Optimistically add the user's message
        final tempUserMessage = Message(
          id: 'temp_user_${DateTime.now().millisecondsSinceEpoch}',
          chatId: _currentChatId!,
          content: event.message,
          isUser: true,
          createdAt: DateTime.now(), // Will be replaced by server timestamp
          updatedAt: DateTime.now(),
        );

        emit(
          currentState.copyWith(
            messages: [...currentState.messages, tempUserMessage],
          ),
        );

        // Send user's message to repository
        final realUserMessage = await _chatRepository.sendMessage(
          user.id,
          _currentChatId!,
          event.message,
          true,
        );

        // Replace temporary message with real one
        final updatedMessages =
            currentState.messages
                .where((m) => m.id != tempUserMessage.id)
                .toList()
              ..add(realUserMessage);

        emit(currentState.copyWith(messages: updatedMessages));

        // Get AI response
        final aiResponse = await _geminiService.getAIResponse(
          event.message,
          updatedMessages,
        );

        // Send AI response (with server timestamp)
        final aiMessage = await _chatRepository.sendMessage(
          user.id,
          _currentChatId!,
          aiResponse,
          false,
        );

        emit(currentState.copyWith(messages: [...updatedMessages, aiMessage]));
      }
    } catch (e) {
      emit(ChatSessionError(errorMessage: e.toString()));
    }
  }

  void _onMessagesUpdated(
    MessagesSessionUpdated event,
    Emitter<ChatSessionState> emit,
  ) {
    if (state is ChatSessionReady) {
      final currentState = state as ChatSessionReady;
      // Merge existing messages with new ones, removing duplicates
      final mergedMessages =
          [...currentState.messages, ...event.messages]
              .fold<Map<String, Message>>({}, (map, message) {
                map[message.id] = message; // Last write wins
                return map;
              })
              .values
              .toList();
      // Sort by server timestamp
      mergedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      emit(currentState.copyWith(messages: mergedMessages));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
