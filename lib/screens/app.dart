import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/helpers/screen_routes.dart';
import 'package:mental_health_support/screens/chat_screen.dart';
import 'package:mental_health_support/screens/create_journal_view.dart';
import 'package:mental_health_support/screens/edit_journal_view.dart';
import 'package:mental_health_support/screens/emergency_screen.dart';
import 'package:mental_health_support/screens/initial_screen.dart';
import 'package:mental_health_support/services/auth/bloc/ChatSessionBloc/chat_session_bloc.dart';
import 'package:mental_health_support/utilities/theme_data.dart';

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
