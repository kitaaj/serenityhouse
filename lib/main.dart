import 'dart:developer' as devtools;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mental_health_support/firebase_options.dart';
import 'package:mental_health_support/helpers/loading/loading_screen.dart';
import 'package:mental_health_support/helpers/nav_cubit.dart';
import 'package:mental_health_support/helpers/screen_routes.dart';
import 'package:mental_health_support/models/achievement.dart';
import 'package:mental_health_support/models/chat.dart';
import 'package:mental_health_support/models/message.dart';
import 'package:mental_health_support/models/mood.dart';
import 'package:mental_health_support/screens/chat_screen.dart';
import 'package:mental_health_support/screens/create_journal_view.dart';
import 'package:mental_health_support/screens/edit_journal_view.dart';
import 'package:mental_health_support/screens/email_verification_view.dart';
import 'package:mental_health_support/screens/emergency_screen.dart';
import 'package:mental_health_support/screens/forgot_password_screen.dart';
import 'package:mental_health_support/screens/login_view.dart';
import 'package:mental_health_support/screens/signup_screen.dart';
import 'package:mental_health_support/services/aiService/ai_service.dart';
import 'package:mental_health_support/services/auth/auth_service.dart';
import 'package:mental_health_support/services/auth/bloc/ChatListBloc/chat_list_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/ChatSessionBloc/chat_session_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/achievementBloc/achievement_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_event.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_state.dart';
import 'package:mental_health_support/services/auth/bloc/journalBloc/journal_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
import 'package:mental_health_support/screens/home_screen.dart';
import 'package:mental_health_support/services/cloud/firebase_cloud_storage.dart';
import 'package:mental_health_support/services/local/repository/achievement_repository.dart';
import 'package:mental_health_support/services/local/repository/chat_repository.dart';
import 'package:mental_health_support/services/local/repository/mood_repository.dart';
import 'package:mental_health_support/theme/theme_manager.dart';
import 'package:mental_health_support/utilities/dependency_injection.dart';
import 'package:mental_health_support/utilities/theme_data.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

extension Log on Object {
  void log() => devtools.log(toString());
}

Future<void> setupLocator() async {
  if (!kIsWeb) {
    final appDocumentDir =
        await path_provider.getApplicationDocumentsDirectory();
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

    'Logging from the main file: Achievements box status: ${achievementsBox.isOpen ? "Open" : "Closed"}'
        .log();
  } catch (e) {
    'Error opening achievements box: $e'.log();
  }

  // Register Services
  getIt.registerSingleton<AuthService>(AuthService.firebase());
  getIt.registerSingleton<GeminiService>(GeminiService());
  getIt.registerSingleton<FirebaseCloudStorage>(FirebaseCloudStorage());

  // Register repositories
  getIt.registerSingleton<ChatRepository>(
    ChatRepository(chatsBox: chatsBox, messagesBox: messagesBox),
  );

  getIt.registerSingleton<HiveMoodRepository>(
    HiveMoodRepository(moodBox: moodsBox),
  );

  getIt.registerSingleton<AchievementRepository>(
    AchievementRepository(achievementBox: achievementsBox),
  );

  // Register BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthService>()));

  getIt.registerFactory<MoodBloc>(
    () => MoodBloc(getIt<FirebaseCloudStorage>(), getIt<HiveMoodRepository>()),
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

  // getIt.registerFactory<AchievementBloc>(
  //   () => AchievementBloc(
  //     getIt<MoodBloc>(),
  //     Hive.box<Achievement>('achievements'),
  //   ),
  // );

  getIt.registerFactory<JournalBloc>(
    () => JournalBloc(getIt<FirebaseCloudStorage>()),
  );

  getIt.registerFactory<NavCubit>(() => NavCubit());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    webProvider: ReCaptchaV3Provider(dotenv.env['RECAPTCHA_V3_SITE_KEY'] ?? ''),
  );

  // Setup Dependency Injection
  await setupLocator();

  runApp(
    ThemeManager(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => getIt<AuthBloc>()..add(const AuthEventInitialize()),
          ),
          BlocProvider<MoodBloc>(create: (_) => getIt<MoodBloc>()),
          BlocProvider<AchievementBloc>(
            create:
                (context) => AchievementBloc(
                  context.read<MoodBloc>(),
                  getIt<AchievementRepository>(),
                ),
          ),
          BlocProvider<ChatListBloc>(create: (_) => getIt<ChatListBloc>()),
          BlocProvider<ChatSessionBloc>(
            create: (_) => getIt<ChatSessionBloc>(),
          ),
          BlocProvider<JournalBloc>(create: (_) => getIt<JournalBloc>()),
          BlocProvider<NavCubit>(create: (_) => getIt<NavCubit>()),
        ],

        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serenity House',
      theme: lightTheme.copyWith(
        appBarTheme: lightTheme.appBarTheme.copyWith(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: lightTheme.scaffoldBackgroundColor,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
      ),
      darkTheme: darkTheme.copyWith(
        appBarTheme: darkTheme.appBarTheme.copyWith(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: darkTheme.scaffoldBackgroundColor,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const InitialScreen(),
      debugShowCheckedModeBanner: false,

      routes: {
        createJournalRoute: (context) => const CreateJournalView(),
        editJournalRoute: (context) => const EditJournalView(),
        emergencyScreenRoute: (context) => const EmergencyScreen(),
        chatRoute: (context) {
          final chatId = ModalRoute.of(context)!.settings.arguments as String;
          return BlocProvider.value(
            value: context.read<ChatSessionBloc>(),
            child: ChatScreen(sessionId: chatId),
          );
        },
        // forgotPasswordRoute: (context) => const ForgotPasswordView(),
        // signupRoute: (context) => const RegisterView(),
        // loginRoute: (context) => const LoginView(),
        // emailVerificationRoute: (context) => const VerifyEmailView(),
      },
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return HomeScreen();
        } else if (state is AuthStateNeedsVerififcation) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
