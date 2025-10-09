import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/profile/profile_router.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/action_button.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/widgets/custom_textfield.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: 'Ayame');
    _lastNameController = TextEditingController(text: 'Nakamura');
    _emailController = TextEditingController(
      text: 'ayame.nakamura@example.com',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    // TODO: Connect to profile update service.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _errorMessage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully.')),
    );
  }

  void _navigateBack() {
    context.pop();
  }

  void _navigateToChangePassword() {
    context.pushNamed(ProfileRoutes.changePasswordName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.secondary,
                    onPressed: _navigateBack,
                  ),
                  Expanded(
                    child: Center(
                      child: CustomText(
                        text: 'Edit Profile',
                        type: CustomTextType.title,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Personal Information',
                      type: CustomTextType.bodyBold,
                      color: AppColors.text,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _firstNameController,
                      hintText: 'First Name',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _lastNameController,
                      hintText: 'Last Name',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      type: TextFieldType.muted,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ActionButton(
                        label: 'Change Password',
                        onPressed: _navigateToChangePassword,
                        type: ButtonType.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_errorMessage != null) ...[
                      CustomText(
                        text: _errorMessage!,
                        type: CustomTextType.body,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ActionButton(
                        label: _isSaving ? 'Saving...' : 'Save',
                        isLoading: _isSaving,
                        onPressed: () => _handleSave(),
                        type: ButtonType.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
