import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/services/auth/auth_provider.dart';
import 'package:mental_health_support/services/auth/auth_user.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_event.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthProvider provider;
  StreamSubscription<AuthUser?>? _authSubscription;

  AuthBloc(this.provider)
    : super(const AuthStateUninitialized(isLoading: true)) {
    _authSubscription = provider.authStateChanges.listen(
      (user) {
        if (user != null) {
          add(AuthEventInitialize());
        } else {
          add(const AuthEventLogOut());
        }
      },
      onError: (e) {
        add(AuthEventLogOut(exception: e));
      },
    );

    // Handle sending email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    // Handle forgot password
    on<AuthEventForgotPasssword>((event, emit) async {
      emit(
        const AuthStateForgotPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: false,
        ),
      );
      final email = event.email;
      if (email == null) {
        return;
      }

      emit(
        const AuthStateForgotPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: true,
        ),
      );

      bool didSendEmail;
      Exception? exception;
      try {
        await provider.sendPasswordReset(toEmail: email);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }

      emit(
        AuthStateForgotPassword(
          exception: exception,
          hasSentEmail: didSendEmail,
          isLoading: false,
        ),
      );
    });

    // Handle user registration
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerififcation(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });

    // Handle should register event
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    });

    // Handle initialization
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerififcation(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    // Handle login
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while we log you in',
        ),
      );

      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(const AuthStateNeedsVerififcation(isLoading: false));
        } else {
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    // Handle logout
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (error) {
        emit(AuthStateLoggedOut(exception: error, isLoading: false));
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
