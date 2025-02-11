import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_event.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_state.dart';
import 'package:mental_health_support/utilities/dialogs/error_dialog.dart';
import 'package:mental_health_support/utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (!context.mounted) return;
          if (state.exception != null) {
            await showErrorDialog(
              context,
              'We could not process your request. Please make sure that you are a registered user.',
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Password reset',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Enter an email address below to receive password reset link.',
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: true,
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Email address...',
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    final email = _controller.text;
                    context.read<AuthBloc>().add(
                      AuthEventForgotPasssword(email: email),
                    );
                  },
                  child: const Text('send password reset link'),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
