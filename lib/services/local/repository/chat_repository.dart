import 'package:hive/hive.dart';
import 'package:mental_health_support/models/chat.dart';
import 'package:mental_health_support/models/message.dart';
import 'package:mental_health_support/services/cloud/firebase_cloud_storage.dart';

class ChatRepository {
  final FirebaseCloudStorage _storage;
  final Box<Chat> chatsBox;
  final Box<Message> messagesBox;

  ChatRepository({
    FirebaseCloudStorage? storage,
    required this.chatsBox,
    required this.messagesBox,
  }) : _storage = storage ?? FirebaseCloudStorage();

  /// **Fetches chats from Hive cache or Firestore if cache is empty or stale**
  Future<List<Chat>> getChats(String userId) async {
    // Attempt to get from Hive
    final cachedChats =
        chatsBox.values.where((chat) => chat.userId == userId).toList();

    if (cachedChats.isNotEmpty) {
      // For future, check if cache is stale and needs refresh
      return cachedChats;
    }

    // If no cached data, fetch from Firestore
    final chats = await _storage.fetchAllChatsOnce(userId);

    // Cache the chats in Hive
    for (var chat in chats) {
      chatsBox.put(chat.chatId, chat);
    }

    return chats;
  }

  /// **Creates a new chat both in Firestore and Hive**
  Future<Chat> createNewChat(String userId) async {
    // Create chat in Firestore
    final newChat = await _storage.createNewChat(userId: userId);

    // Cache the new chat in Hive
    chatsBox.put(newChat.chatId, newChat);

    return newChat;
  }

  /// **Streams chats from Firestore and updates Hive cache**
  Stream<List<Chat>> watchAllChats(String userId) {
    return _storage.allChats(userId).map((chats) {
      // Update Hive cache
      for (var chat in chats) {
        chatsBox.put(chat.chatId, chat);
      }
      return chats;
    });
  }

  /// **Loads messages for a specific chat from Hive or Firestore**
  Future<List<Message>> getMessages(String userId, String chatId) async {
    final cachedMessages =
        messagesBox.values.where((msg) => msg.chatId == chatId).toList();

    if (cachedMessages.isNotEmpty) {
      return cachedMessages;
    }

    final messages = await _storage.fetchMessagesOnce(
      userId,
      chatId,
      limit: 100,
    );

    // Cache messages in Hive
    for (var message in messages) {
      messagesBox.put(message.id, message);
    }

    return messages;
  }

  /// **Sends a new message both to Firestore and Hive**
  Future<Message> sendMessage(
    String userId,
    String chatId,
    String content,
    bool isUser,
  ) async {
    // Create message in Firestore
    final message = await _storage.createMessage(
      userId: userId,
      sessionId: chatId,
      content: content,
      isUser: isUser,
    );

    // Cache the message in Hive
    messagesBox.put(message.id, message);

    // Update chat in Hive
    final chat = chatsBox.get(chatId);
    if (chat != null) {
      final updatedChat = chat.copyWith(
        latestMessage:
            content.length > 20 ? '${content.substring(0, 20)}...' : content,
        updatedAt: message.createdAt,
        messageCount: chat.messageCount + 1,
        unreadCount: isUser ? 0 : (chat.unreadCount + 1),
      );
      chatsBox.put(chat.chatId, updatedChat);
    }

    return message;
  }

  /// **Deletes a message from Firestore and Hive**
  Future<void> deleteMessage({
    required String userId,
    required String chatId,
    required String documentId,
  }) async {
    // Delete from Firestore
    await _storage.deleteMessage(
      userId: userId,
      sessionId: chatId,
      documentId: documentId,
    );
    // Delete from Hive
    messagesBox.delete(documentId);
  }

  /// **Updates a message in Firestore and Hive**
  Future<void> updateMessage({
    required String userId,
    required String chatId,
    required String documentId,
    required String content,
  }) async {
    // Update in Firestore
    await _storage.updateMessage(
      userId: userId,
      sessionId: chatId,
      documentId: documentId,
      content: content,
    );

    // Update in Hive
    final message = messagesBox.get(documentId);
    if (message != null) {
      final updatedMessage = message.copyWith(
        content: content,
        updatedAt: DateTime.now(),
      );
      messagesBox.put(documentId, updatedMessage);
    }
  }

  /// **Resets the unread count for a chat**
  Future<void> resetUnreadCount({
    required String userId,
    required String chatId,
  }) async {
    await _storage.resetUnreadCount(userId: userId, sessionId: chatId);

    // Update in Hive
    final chat = chatsBox.get(chatId);
    if (chat != null) {
      final updatedChat = chat.copyWith(unreadCount: 0);
      chatsBox.put(chat.chatId, updatedChat);
    }
  }

  /// **Streams messages for a specific chat and updates Hive cache**
  Stream<List<Message>> watchMessages(String userId, String chatId) {
    return _storage.getChatMessages(chatId, userId).map((messages) {
      for (var message in messages) {
        messagesBox.put(message.id, message);
      }
      return messages;
    });
  }

  /// **Disposes Hive boxes**
  Future<void> dispose() async {
    await chatsBox.close();
    await messagesBox.close();
  }
}
