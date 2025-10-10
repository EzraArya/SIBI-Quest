import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/widgets/custom_textfield.dart';
import 'package:sibi_quest/shared/widgets/action_button.dart';
import 'package:sibi_quest/features/auth/auth_router.dart';
import 'package:sibi_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:sibi_quest/features/dashboard/dashboard_router.dart';
import 'package:sibi_quest/features/auth/domain/auth_failure.dart';
import 'package:sibi_quest/features/onboarding/onboarding_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          final message = error is AuthFailure
              ? error.message
              : 'Something went wrong. Please try again.';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
        data: (_) {
          final wasLoading = previous?.isLoading ?? false;
          if (wasLoading) {
            context.go(DashboardRoutes.homePath);
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final emailText = _emailController.text.trim();
    final passwordText = _passwordController.text.trim();

    String? emailError;
    String? passwordError;

    if (emailText.isEmpty) {
      emailError = 'Email is required';
    } else {
      final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailPattern.hasMatch(emailText)) {
        emailError = 'Enter a valid email address';
      }
    }

    if (passwordText.isEmpty) {
      passwordError = 'Password is required';
    }

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    if (emailError != null || passwordError != null) {
      return;
    }

    FocusScope.of(context).unfocus();
    ref
        .read(authControllerProvider.notifier)
        .signIn(email: emailText, password: passwordText);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.secondary),
                    onPressed: () {
                      context.go(OnboardingRoutes.welcomePath);
                    },
                  ),
                  const Spacer(),
                  CustomText(
                    text: "Enter your details",
                    type: CustomTextType.title,
                    color: AppColors.text,
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 40),
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
                onChanged: (_) {
                  if (_emailError != null) {
                    setState(() {
                      _emailError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
                errorText: _passwordError,
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() {
                      _passwordError = null;
                    });
                  }
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ActionButton(
                      label: 'SIGN IN',
                      type: ButtonType.primary,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        context.go(AuthRoutes.signupPath);
                      },
                      child: const Text('Need an account? Sign up'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
