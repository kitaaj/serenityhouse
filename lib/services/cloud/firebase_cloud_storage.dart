import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_health_support/models/chat.dart';
import 'package:mental_health_support/models/message.dart';
import 'package:mental_health_support/models/mood.dart';
import 'package:mental_health_support/services/cloud/cloud_journal_entry.dart';
import 'package:mental_health_support/services/cloud/cloud_storage_constants.dart';
import 'package:mental_health_support/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Messages CRUD Methods
  Future<Message> createMessage({
    required String userId,
    required String content,
    required bool isUser,
    required String sessionId,
  }) async {
    final chatRef = firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(sessionId);

    final messagesRef = chatRef.collection('messages');

    final timestamp = FieldValue.serverTimestamp();

    // Add message to subcollection
    final messageRef = await messagesRef.add({
      contentFieldName: content,
      isUserFieldName: isUser,
      messageChatIdFieldName: sessionId,
      messageCreatedAtFieldName: timestamp,
      messageUpdatedAtFieldName: timestamp,
    });

    final messageSnapshot = await messageRef.get();
    final message = Message.fromSnapshot(messageSnapshot);

    // Update chat metadata
    final chatDoc = await chatRef.get();
    final chatData = chatDoc.data() as Map<String, dynamic>;
    final int newMessageCount = (chatData['messageCount'] ?? 0) + 1;

    // Update chat title with first message preview
    String newTitle = chatData[chatTitleFieldName] ?? 'New Chat';
    if (newMessageCount == 1 && isUser) {
      newTitle =
          content.length > 20 ? '${content.substring(0, 20)}...' : content;
    }

    await chatRef.update({
      chatTitleFieldName: newTitle,
      latestMessageFieldName: content,
      chatUpdatedAtFieldName: FieldValue.serverTimestamp(),
      messageCountFieldName: newMessageCount,
      unreadCountFieldName: isUser ? 0 : (chatData['unreadCount'] ?? 0) + 1,
    });

    return message;
  }

  Stream<List<Message>> getChatMessages(String sessionId, String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(sessionId)
        .collection('messages')
        .orderBy(messageCreatedAtFieldName, descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Message.fromSnapshot(doc)).toList(),
        );
  }

  Future<List<Message>> fetchMessagesOnce(
    String userId,
    String sessionId, {
    int limit = 100,
  }) async {
    final snapshot =
        await firestore
            .collection('users')
            .doc(userId)
            .collection('chats')
            .doc(sessionId)
            .collection('messages')
            .orderBy(messageCreatedAtFieldName, descending: false)
            .limit(limit)
            .get();

    final messages =
        snapshot.docs.map((doc) => Message.fromSnapshot(doc)).toList();
    return messages; // Oldest first
  }

  Future<void> updateMessage({
    required String userId,
    required String sessionId,
    required String documentId,
    required String content,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(sessionId)
        .collection('messages')
        .doc(documentId)
        .update({contentFieldName: content});
  }

  Future<void> deleteMessage({
    required String userId,
    required String sessionId,
    required String documentId,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(sessionId)
        .collection('messages')
        .doc(documentId)
        .delete();
  }

  Future<void> resetUnreadCount({
    required String userId,
    required String sessionId,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(sessionId)
        .update({unreadCountFieldName: 0});
  }

  // Chat Sessions CRUD Methods
  Future<Chat> createNewChat({required String userId}) async {
    final chatsRef = firestore
        .collection('users')
        .doc(userId)
        .collection('chats');

    final docRef = chatsRef.doc();

    final newChatData = {
      ownerUserIdFieldName: userId,
      chatTitleFieldName: 'New Chat',
      chatCreatedAtFieldName: DateTime.now(),
      chatUpdatedAtFieldName: DateTime.now(),
      messageCountFieldName: 0,
      latestMessageFieldName: null,
      unreadCountFieldName: 0,
    };

    await docRef.set(newChatData);

    final snapshot = await docRef.get();

    return Chat.fromSnapshot(snapshot);
  }

  Stream<List<Chat>> allChats(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .orderBy(chatUpdatedAtFieldName, descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Chat.fromSnapshot(doc)).toList(),
        );
  }

  Future<List<Chat>> fetchAllChatsOnce(String userId) async {
    final snapshot =
        await firestore
            .collection('users')
            .doc(userId)
            .collection('chats')
            .orderBy(chatUpdatedAtFieldName, descending: true)
            .get();

    return snapshot.docs.map((doc) => Chat.fromSnapshot(doc)).toList();
  }

  // Moods CRUD Methods
  Future<MoodEntry> createMood({
    required String label,
    required String userId,
    required String? notes,
    required List<String>? tags,
  }) async {
    final document = await firestore.collection('moods').add({
      ownerUserIdFieldName: userId,
      moodFieldName: label,
      moodNotesFieldName: notes,
      moodTagsFieldName: tags,
      moodDateFieldName: FieldValue.serverTimestamp(),
    });
    final fetchMood = await document.get();

    return MoodEntry(
      id: fetchMood.id,
      userId: userId,
      label: label,
      notes: notes,
      tags: tags,
      date: fetchMood.data()![moodDateFieldName],
    );
  }

  Stream<Iterable<MoodEntry>> allMoods(String userId) {
    return firestore
        .collection('moods')
        .where(ownerUserIdFieldName, isEqualTo: userId)
        .orderBy(moodDateFieldName, descending: true)
        .snapshots()
        .map((event) => event.docs.map((doc) => MoodEntry.fromSnapshot(doc)));
  }

  Future<void> updateMood({
    required String documentId,
    required String newMood,
  }) async {
    await firestore.collection('moods').doc(documentId).update({
      moodFieldName: newMood,
    });
  }

  Future<void> deleteMood({required String documentId}) async {
    await firestore.collection('moods').doc(documentId).delete();
  }

  // Journals CRUD Methods
  Future<JournalEntry> createJournalEntry({
    required String userId,
    required String content,
  }) async {
    final document = await firestore.collection('journals').add({
      ownerUserIdFieldName: userId,
      journalContentFieldName: content,
    });
    final fetchJournal = await document.get();
    return JournalEntry(
      documentId: fetchJournal.id,
      userId: userId,
      content: content,
    );
  }

  Future<void> updateJournalEntry({
    required String documentId,
    required String content,
    // required String userId,
  }) async {
    await firestore.collection('journals').doc(documentId).update({
      journalContentFieldName: content,
    });
  }

  Future<void> deleteJournalEntry({required String documentId}) async {
    try {
      await firestore.collection('journals').doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteEntryException();
    }
  }

  Stream<Iterable<JournalEntry>> allJournalEntries({required String userId}) {
    final allJournalEntries = firestore
        .collection('journals')
        .where(ownerUserIdFieldName, isEqualTo: userId)
        .snapshots()
        .map(
          (event) => event.docs.map((doc) => JournalEntry.fromSnapshot(doc)),
        );
    return allJournalEntries;
  }
}
