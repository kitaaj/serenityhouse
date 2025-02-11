import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mental_health_support/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final Exception? exception;
  final String? loadingText;

  const AuthState({
    required this.isLoading,
    this.exception,
    this.loadingText = 'Please wait a moment',
  });
}

class AuthStateRegistering extends AuthState {
  const AuthStateRegistering({
    required super.isLoading,
    super.exception,
  });
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required super.isLoading});
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;

  const AuthStateLoggedIn({
    required this.user,
    required super.isLoading,
    super.exception,
    super.loadingText,
  });
}

class AuthStateNeedsVerififcation extends AuthState {
  const AuthStateNeedsVerififcation({required super.isLoading});
}

class AuthStateForgotPassword extends AuthState {
  final bool hasSentEmail;

  const AuthStateForgotPassword({
    required super.isLoading,
    required this.hasSentEmail,
    super.exception,
  });
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  const AuthStateLoggedOut({
    required super.isLoading,
    super.exception,
    super.loadingText,
  });

  @override
  List<Object?> get props => [exception, isLoading, loadingText];
}