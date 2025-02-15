import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mental_health_support/firebase_options.dart';
import 'package:mental_health_support/helpers/nav_cubit.dart';
import 'package:mental_health_support/screens/app.dart';
import 'package:mental_health_support/services/auth/bloc/ChatListBloc/chat_list_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/ChatSessionBloc/chat_session_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/achievementBloc/achievement_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_event.dart';
import 'package:mental_health_support/services/auth/bloc/journalBloc/journal_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_event.dart';
import 'package:mental_health_support/services/local/repository/achievement_repository.dart';
import 'package:mental_health_support/theme/theme_manager.dart';
import 'package:mental_health_support/utilities/dependency_injection.dart';
import 'package:mental_health_support/utilities/set_up_locator.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  final recaptchaKey = dotenv.env['RECAPTCHA_V3_SITE_KEY'] ?? '';
  assert(recaptchaKey.isNotEmpty, 'RECAPTCHA_V3_SITE_KEY is missing in .env');
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    webProvider: ReCaptchaV3Provider(recaptchaKey),
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
          BlocProvider<MoodBloc>(
            create: (_) => getIt<MoodBloc>()..add(LoadMoodsEvent()),
          ),
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
