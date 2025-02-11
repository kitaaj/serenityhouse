import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Email Verification',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "We've just sent a verification email in your inbox.",
              ),
              const Text(
                "Click the link below if you haven't received an email yet.",
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventSendEmailVerification(),
                      );
                },
                child: const Text(
                  'Resend verification email.',
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Restart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
