import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/services/auth/auth_exceptions.dart';
import 'package:mental_health_support/services/auth/auth_service.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_event.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_state.dart';
import 'package:mental_health_support/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context,
              'Cannot find any user with the entered credentials.',
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // const SizedBox(height: 40),
                        // Image.asset(
                        //   'assets/images/logo.png', // Replace with your logo asset
                        //   height: 100,
                        // ),
                        const SizedBox(height: 20),
                        Text(
                          'Welcome Back!',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Please sign in to continue',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: _email,
                          enableSuggestions: false,
                          autocorrect: false,
                          autofocus: true,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final email = _email.text;
                            final password = _password.text;
                            context.read<AuthBloc>().add(
                              AuthEventLogIn(email, password),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          child: Text(
                            'Login',
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: TextButton(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(
                                      const AuthEventShouldRegister(),
                                    );
                                  },
                                  child: const Text(
                                    "Not registered? Register here",
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: TextButton(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(
                                      const AuthEventForgotPasssword(),
                                    );
                                  },
                                  child: const Text('Forgot password?'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              default:
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
            }
          },
        ),
      ),
    );
  }
}
