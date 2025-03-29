import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:nlp_flutter/Screens/Authentication/fed_login.dart';
import '../../Utilities/helpers.dart';
import 'sign_up_screen.dart';
import '../../Utilities/constants.dart';
import '../../ViewModels/auth_vm.dart';
import '../../Views/three_loading_indicator.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signIn(String username, String password) async {
    setState(() {
      isLoading = true;
    });

    try {
      await ref.read(authViewModelProvider.notifier).signIn(username, password);
    } finally {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 2000));

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authViewModelProvider);
    final authVM = ref.read(authViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 70),
              UiUtils.buildTextField(
                controller: emailController,
                label: "Email",
                isPassword: false,
                onToggleObscureText: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 30),
              UiUtils.buildTextField(
                controller: passwordController,
                label: "Password",
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleObscureText: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () => _signIn(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  minimumSize: const Size(400, 60),
                ),
                child:
                    isLoading
                        ? const ThreeDotsLoadingIndicator()
                        : const Text("Login", style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              SignUpScreen(),
                      transitionDuration:
                          Duration.zero, // No transition duration
                      reverseTransitionDuration:
                          Duration.zero, // No reverse transition duration
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        return FadeTransition(
                          opacity: animation, // Instant fade-in and fade-out
                          child: child,
                        );
                      },
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.text,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                  minimumSize: const Size(400, 60),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text("Don't have an account? Sign up!"),
              ),

              const SizedBox(height: 30),
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Divider(color: AppColors.text, thickness: 1),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "or",
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: AppColors.text, thickness: 1),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                child: FlutterSocialButton(
                  onTap: () {
                    AuthService().signInWithHostedUI();
                  },
                  buttonType: ButtonType.google,
                ),
              ),
              SizedBox(
                child: FlutterSocialButton(
                  onTap: () {
                    authVM.federatedSignInWithGoogle();
                  },
                  buttonType: ButtonType.google,
                ),
              ),
              SizedBox(
                child: FlutterSocialButton(
                  onTap: () {
                    authVM.signInWithWebUIGoogle();
                  },
                  buttonType: ButtonType.google,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
