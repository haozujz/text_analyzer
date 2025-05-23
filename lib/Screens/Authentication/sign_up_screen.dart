import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Utilities/constants.dart';
import '../../Utilities/helpers.dart';
import '../../ViewModels/auth_vm.dart';
import '../../Views/three_loading_indicator.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController verificationCodeController =
      TextEditingController();
  bool _isLoading = false;
  bool _isVerificationButtonJustTapped = false;
  bool _obscurePassword = true;

  Future<void> _signUp(String email, String verificationCode) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authViewModelProvider.notifier)
          .confirmSignUp(email, verificationCode);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getVerificationCode(String email, String password) async {
    setState(() {
      _isVerificationButtonJustTapped = true;
    });

    try {
      await ref.read(authViewModelProvider.notifier).signUp(email, password);
      await Future.delayed(const Duration(seconds: 8));
    } finally {
      setState(() {
        _isVerificationButtonJustTapped = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authViewModelProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Create an Account",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 50),
              UiUtils.buildTextField(
                controller: emailController,
                label: "Email",
                isPassword: false,
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
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed:
                    _isVerificationButtonJustTapped
                        ? () => ()
                        : () => _getVerificationCode(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isVerificationButtonJustTapped
                          ? CupertinoColors.systemGrey
                          : AppColors.button,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(400, 50),
                ),
                child:
                    _isVerificationButtonJustTapped
                        ? Text("Please Wait")
                        : Text("Get Verification Code"),
              ),
              const SizedBox(height: 30),
              UiUtils.buildTextField(
                controller: verificationCodeController,
                label: "Verification Code",
                isPassword: false,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : () => _signUp(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(400, 60),
                ),
                child:
                    _isLoading
                        ? const ThreeDotsLoadingIndicator()
                        : const Text("Sign Up", style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.text,
                  minimumSize: const Size(400, 60),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text("Already have an account? Log in!"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
