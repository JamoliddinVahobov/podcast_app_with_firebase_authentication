import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:podcast_app/features/auth/logic/auth_event.dart';
import '../../logic/auth_bloc.dart';
import '../../logic/auth_state.dart';
import '../widgets/custom_button.dart';

class VerificationPage extends StatelessWidget {
  const VerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'A verification email has been sent to your email address. Please verify your email and login.',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Sent to: ${user?.email ?? ""}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is EmailResent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is AuthError &&
                    state.source == 'resend_verification_error') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const CircularProgressIndicator();
                }
                return TextButton(
                  onPressed: () {
                    if (user != null) {
                      context.read<AuthBloc>().add(
                            ResendVerificationEmail(user: user),
                          );
                    }
                  },
                  child: const Text(
                    'Resend Verification Email',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            CustomButton(
              label: 'Go to Login page',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              colors: [Colors.blue.shade700, Colors.blue.shade600],
            ),
          ],
        ),
      ),
    );
  }
}
