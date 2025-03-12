import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:nlp_flutter/main.dart';

class LoginScreen extends StatelessWidget {
  final AuthenticatorState state;
  const LoginScreen(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome Back!", style: TextStyle(fontSize: 24)),
            TextField(
              decoration: const InputDecoration(labelText: "Email"),
              onChanged: (value) => state.username = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
              onChanged: (value) => state.password = value,
            ),
            ElevatedButton(onPressed: state.signIn, child: const Text("Login")),
            TextButton(
              onPressed: () => state.changeStep(AuthenticatorStep.signUp),
              child: const Text("Create an account"),
            ),
          ],
        ),
      ),
    );
  }
}

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          await Amplify.Auth.signOut();

          // Ensure the widget is still mounted before navigating
          if (!context.mounted) return;

          // Navigate to the login screen after sign-out
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyApp()),
          );
        } catch (e) {
          safePrint('Error signing out: $e');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red, // Button color
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      child: const Text("Sign Out"),
    );
  }
}
