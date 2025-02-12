import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:mental_health_support/models/mood.dart';
import 'package:mental_health_support/models/chat.dart';
import 'package:mental_health_support/helpers/logger.dart';
import 'package:mental_health_support/models/message.dart';
import 'package:mental_health_support/helpers/nav_cubit.dart';
import 'package:mental_health_support/models/achievement.dart';
import 'package:mental_health_support/services/local/repository/firebase_mood_repository.dart';
import 'package:mental_health_support/services/local/repository/hive_mood_repository.dart';
import 'package:mental_health_support/services/local/repository/mood_repository.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:mental_health_support/services/auth/auth_service.dart';
import 'package:mental_health_support/services/aiService/ai_service.dart';
import 'package:mental_health_support/utilities/dependency_injection.dart';
import 'package:mental_health_support/services/cloud/firebase_cloud_storage.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_bloc.dart';
import 'package:mental_health_support/services/local/repository/chat_repository.dart';
import 'package:mental_health_support/services/auth/bloc/journalBloc/journal_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/ChatListBloc/chat_list_bloc.dart';
import 'package:mental_health_support/services/local/repository/achievement_repository.dart';
import 'package:mental_health_support/services/auth/bloc/ChatSessionBloc/chat_session_bloc.dart';

Future<void> setupLocator() async {
  // Initialize Hive
  if (!kIsWeb) {
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  } else {
    Hive.init(
      'hive_storage',
      backendPreference: HiveStorageBackendPreference.webWorker,
    );
  }

  // Register Hive adapters
  Hive.registerAdapter(ChatAdapter());
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(AchievementAdapter());
  Hive.registerAdapter(MoodEntryAdapter());

  // Open Hive boxes
  final chatsBox = await Hive.openBox<Chat>('chatsBox');
  final messagesBox = await Hive.openBox<Message>('messagesBox');
  final moodsBox = await Hive.openBox<MoodEntry>('moodsBox');
  final achievementsBox = await Hive.openBox<Achievement>('achievements');

  'Logging from the main file: Opening Hive achievements box...'.log();
  try {
    final achievementsBox = await Hive.openBox<Achievement>('achievements');
    'Logging from the main file: Achievements box status: ${achievementsBox.isOpen ? "Open" : "Closed"}'.log();
  } catch (e) {
    'Error opening achievements box: $e'.log();
  }

  // Register Services
  getIt.registerSingleton<AuthService>(AuthService.firebase());
  getIt.registerSingleton<GeminiService>(GeminiService());
  getIt.registerSingleton<FirebaseCloudStorage>(FirebaseCloudStorage());

  // Register Repositories
  getIt.registerSingleton<ChatRepository>(
    ChatRepository(chatsBox: chatsBox, messagesBox: messagesBox),
  );

  getIt.registerSingleton<HiveMoodRepository>(
    HiveMoodRepository(moodBox: moodsBox),
  );

  getIt.registerSingleton<AchievementRepository>(
    AchievementRepository(achievementBox: achievementsBox),
  );

  // Register MoodRepository (combines Firestore and Hive)
  getIt.registerSingleton<MoodRepository>(
    FirebaseMoodRepository(
      firestore: getIt<FirebaseCloudStorage>(),
      hive: getIt<HiveMoodRepository>(),
      userId: getIt<AuthService>().currentUser!.id,
    ),
  );

  // Register BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthService>()));

  getIt.registerFactory<MoodBloc>(
    () => MoodBloc(getIt<MoodRepository>()), // Updated to use MoodRepository
  );

  getIt.registerFactory<ChatSessionBloc>(
    () => ChatSessionBloc(
      chatRepository: getIt<ChatRepository>(),
      geminiService: getIt<GeminiService>(),
      authService: getIt<AuthService>(),
    ),
  );

  getIt.registerFactory<ChatListBloc>(
    () => ChatListBloc(
      chatRepository: getIt<ChatRepository>(),
      authService: getIt<AuthService>(),
    ),
  );

  getIt.registerFactory<JournalBloc>(
    () => JournalBloc(getIt<FirebaseCloudStorage>()),
  );

  getIt.registerFactory<NavCubit>(() => NavCubit());
}