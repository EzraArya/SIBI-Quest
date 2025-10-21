import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/custom_textfield.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/widgets/action_button.dart';

import 'package:sibi_quest/features/auth/auth_router.dart';
import 'package:sibi_quest/features/auth/domain/auth_failure.dart';
import 'package:sibi_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:sibi_quest/features/dashboard/dashboard_router.dart';
import 'package:sibi_quest/features/onboarding/onboarding_router.dart';
import 'package:sibi_quest/cores/models/user.dart' as core;

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _ageError;
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  late final ProviderSubscription<AsyncValue<void>> _authListener;

  @override
  void initState() {
    super.initState();

    // Add listener to detect and fix Android autofill concatenation bug
    _emailController.addListener(_sanitizeEmailField);

    _authListener = ref.listenManual<AsyncValue<void>>(authControllerProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (error, _) {
          final message = error is AuthFailure
              ? error.message
              : 'Failed to sign up. Please try again.';
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
    _emailController.removeListener(_sanitizeEmailField);
    _authListener.close();
    _ageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _sanitizeEmailField() {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Remove password if concatenated at the end (Android autofill bug)
    if (password.isNotEmpty &&
        email.endsWith(password) &&
        email.length > password.length) {
      final cleanEmail = email.substring(0, email.length - password.length);
      if (cleanEmail.contains('@')) {
        _emailController.value = _emailController.value.copyWith(
          text: cleanEmail,
          selection: TextSelection.collapsed(offset: cleanEmail.length),
        );
      }
    }
  }

  bool _validateCurrentPage() {
    bool isValid = true;
    String errorMsg = "This field must not be empty";
    setState(() {
      // Clear previous errors before validating again
      _ageError = null;
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;

      switch (_currentPage) {
        case 0:
          if (_ageController.text.trim().isEmpty) {
            _ageError = errorMsg;
            isValid = false;
          } else {
            int? age = int.tryParse(_ageController.text.trim());
            if (age == null || age <= 0) {
              _ageError = 'Please enter a valid age';
              isValid = false;
            }
          }
          break;
        case 1:
          if (_firstNameController.text.trim().isEmpty) {
            _firstNameError = errorMsg;
            isValid = false;
          }
          if (_lastNameController.text.trim().isEmpty) {
            _lastNameError = errorMsg;
            isValid = false;
          }
          break;
        case 2:
          if (_emailController.text.trim().isEmpty) {
            _emailError = errorMsg;
            isValid = false;
          } else {
            // Simple email regex pattern
            final emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
            final regExp = RegExp(emailPattern);
            if (!regExp.hasMatch(_emailController.text.trim())) {
              _emailError = 'Please enter a valid email address';
              isValid = false;
            }
          }
          break;
        case 3:
          if (_passwordController.text.isEmpty) {
            _passwordError = errorMsg;
            isValid = false;
          }
          if (_confirmPasswordController.text.isEmpty) {
            _confirmPasswordError = 'Please confirm your password';
            isValid = false;
          } else if (_passwordController.text !=
              _confirmPasswordController.text) {
            _confirmPasswordError = 'Passwords do not match';
            isValid = false;
          }
          break;
      }
    });
    return isValid;
  }

  void nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Widget> get _pages => [
    // Page 1: Enter age
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'How old are you?',
          type: CustomTextType.title,
          color: AppColors.text,
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _ageController,
          hintText: 'Age',
          keyboardType: TextInputType.number,
          errorText: _ageError,
        ),
      ],
    ),
    // Page 2: Enter first and last name
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "What's your name?",
          type: CustomTextType.title,
          color: AppColors.text,
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _firstNameController,
          hintText: 'First Name',
          errorText: _firstNameError,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _lastNameController,
          hintText: 'Last Name',
          errorText: _lastNameError,
        ),
      ],
    ),
    // Page 3: Enter email address
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'What is your email address?',
          type: CustomTextType.title,
          color: AppColors.text,
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _emailController,
          hintText: 'Email',
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
          autofillHints: null,
        ),
      ],
    ),
    // Page 4: Enter password
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Create a password',
          type: CustomTextType.title,
          color: AppColors.text,
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Password',
          obscureText: true,
          errorText: _passwordError,
          autofillHints: null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _confirmPasswordController,
          hintText: 'Confirm Password',
          obscureText: true,
          errorText: _confirmPasswordError,
          autofillHints: null,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading && _currentPage == 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.secondary),
                    onPressed: () {
                      if (_currentPage > 0) {
                        prevPage();
                      } else {
                        context.go(OnboardingRoutes.welcomePath);
                      }
                    },
                  ),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: (_currentPage + 1) / 4,
                      ),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: AppColors.trackbar,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.secondary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _pages[index],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ActionButton(
                  label: _currentPage < 3 ? 'Next' : 'Finish',
                  type: ButtonType.primary,
                  isLoading: isLoading,
                  onPressed: () {
                    if (_validateCurrentPage()) {
                      if (_currentPage < 3) {
                        nextPage();
                      } else {
                        if (authState.isLoading) {
                          return;
                        }

                        // Sanitize email to prevent Android autofill concatenation bug
                        String email = _emailController.text.trim();
                        final password = _passwordController.text;

                        if (password.isNotEmpty &&
                            email.endsWith(password) &&
                            email.length > password.length &&
                            email
                                .substring(0, email.length - password.length)
                                .contains('@')) {
                          email = email.substring(
                            0,
                            email.length - password.length,
                          );
                        }

                        final user = core.User(
                          firstName: _firstNameController.text.trim(),
                          lastName: _lastNameController.text.trim(),
                          email: email,
                          age: int.tryParse(_ageController.text.trim()) ?? 0,
                          currentLevel: null,
                          image: null,
                        );

                        ref
                            .read(authControllerProvider.notifier)
                            .signUp(user: user, password: password);
                      }
                    }
                  },
                ),
              ),
            ),
            if (_currentPage == 0)
              TextButton(
                onPressed: () {
                  context.go(AuthRoutes.loginPath);
                },
                child: const Text('Already have an account? Sign in'),
              )
            else if (_currentPage == 3)
              TextButton(
                onPressed: () {
                  context.go(AuthRoutes.loginPath);
                },
                child: const Text('Already registered? Sign in'),
              ),
          ],
        ),
      ),
    );
  }
}
