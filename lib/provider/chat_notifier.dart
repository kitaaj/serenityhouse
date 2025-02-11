// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:mental_health_support/models/gemini_config.dart';
// import 'package:mental_health_support/services/cloud/cloud_message.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// final currentChatProvider = StateProvider<String?>((ref) => null);
// final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>((ref) {
//   final sharedPreferences = ref.watch(sharedPreferencesProvider);
//   return ChatNotifier(ref, sharedPreferences);
// });

// final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
//   throw UnimplementedError('Override with SharedPreferences instance');
// });

// class ChatNotifier extends StateNotifier<List<Message>> {
//   final Ref _ref;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late CollectionReference _chatsCollection;
//   late CollectionReference _messagesCollection;
//   final SharedPreferences _prefs;

//   ChatNotifier(this._ref, this._prefs) : super([]) {
//     Future.microtask(() => _init());
//   }

//   Future<void> _init() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     _chatsCollection = _firestore
//         .collection('users')
//         .doc(user.uid)
//         .collection('chats');

//     // Load last active chat or create first one
    
//   }

//   final GenerativeModel _model = GenerativeModel(
//     model: 'gemini-1.5-flash',
//     apiKey: GeminiConfig.apiKey,
//     safetySettings: _parseSafetySettings(),
//     generationConfig: _parseGenerationConfig(),
//   );

  // static List<SafetySetting> _parseSafetySettings() {
  //   return [
  //     SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
  //     SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
  //     SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
  //     SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
  //   ];
  // }

//   static GenerationConfig _parseGenerationConfig() {
//     return GenerationConfig(
//       temperature: 0.0,
//       topK: 1,
//       topP: 1,
//       maxOutputTokens: 2048,
//     );
//   }

//   Future<String> getAIResponse(String input) async {
//     final prompt = _buildPrompt(input);
//     final response = await _model.generateContent([Content.text(prompt)]);
//     return response.text ?? "I couldn't generate a response. Please try again.";
//   }

//   String _buildPrompt(String userInput) {
//     return '''
//     [SYSTEM ROLE]
//     You are a licensed mental health professional specializing in CBT and DBT. 
//     Provide empathetic support while maintaining professional boundaries.
    
//     [CONVERSATION HISTORY]
//     ${state.map((m) => "${m.isUser ? 'User' : 'AI'}: ${m.content}").join('\n')}
    
//     [NEW MESSAGE]
//     User: $userInput
//     AI: 
//     ''';
//   }

 

  
//   void addMessage(Message message) async {
//     // Add user message
//     state = [...state, message];
//     await _saveMessage(message);

//     // Get AI response
//     final aiResponse = await getAIResponse(message.content);

//     // Create and save AI message
//     final aiMessage = Message(
//       content: aiResponse,
//       isUser: false,
//       timestamp: DateTime.now(), documentId: '',
//     );

//     state = [...state, aiMessage];
//     await _saveMessage(aiMessage);
//   }

//   Future<void> _saveMessage(Message message) async {
//     await _messagesCollection.add({
//       'content': message.content,
//       'isUser': message.isUser,
//       'timestamp': FieldValue.serverTimestamp(),
//     });

//     await _chatsCollection.doc(_ref.read(currentChatProvider)).update({
//       'title': message.content.substring(
//         0,
//         message.content.length.clamp(0, 20),
//       ),
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }
// }
