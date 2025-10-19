import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sibi_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:sibi_quest/features/profile/presentation/providers/profile_providers.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/action_button.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';

class EditProfilePicturePage extends ConsumerStatefulWidget {
  const EditProfilePicturePage({super.key});

  @override
  ConsumerState<EditProfilePicturePage> createState() =>
      _EditProfilePicturePageState();
}

class _EditProfilePicturePageState
    extends ConsumerState<EditProfilePicturePage> {
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _selectedImageBytes;
  bool _uploadSuccess = false;
  String? _errorMessage;

  void _navigateBack() {
    context.pop();
  }

  Future<void> _handleSelectPhoto() async {
    setState(() {
      _errorMessage = null;
      _uploadSuccess = false;
    });

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        return;
      }

      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to select image: $error';
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedImageBytes == null || _selectedImageBytes!.isEmpty) {
      setState(() {
        _errorMessage = 'Please select a photo before uploading.';
      });
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || currentUser.id == null) {
      setState(() {
        _errorMessage = 'You need to be signed in to upload a profile photo.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _uploadSuccess = false;
    });

    try {
      await ref
          .read(profileControllerProvider.notifier)
          .uploadProfileImage(
            imageBytes: _selectedImageBytes!,
            userId: currentUser.id!,
          );
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _uploadSuccess = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture updated successfully.')),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedImageBytes = null;
      _uploadSuccess = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final isUploading = profileState.isLoading;

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
                        text: 'Change Profile Picture',
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
                  children: [
                    _buildPreview(),
                    const SizedBox(height: 24),
                    CustomText(
                      text:
                          'Choose a clear photo where your hands and face are visible. This helps others recognise you in the community.',
                      type: CustomTextType.body,
                      color: AppColors.placeholder,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ActionButton(
                        label: 'Select New Photo',
                        onPressed: _handleSelectPhoto,
                        type: ButtonType.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedImageBytes != null)
                      SizedBox(
                        width: double.infinity,
                        child: ActionButton(
                          label: isUploading
                              ? 'Uploading...'
                              : 'Update Profile Picture',
                          isLoading: isUploading,
                          onPressed: () {
                            if (!isUploading) {
                              _handleUpload();
                            }
                          },
                          type: ButtonType.primary,
                        ),
                      ),
                    if (_selectedImageBytes != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ActionButton(
                          label: 'Cancel Selection',
                          onPressed: _clearSelection,
                          type: ButtonType.muted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (isUploading)
                      const _StatusRow(
                        icon: Icons.sync_rounded,
                        color: AppColors.placeholder,
                        message: 'Uploading...',
                      ),
                    if (_uploadSuccess)
                      const _StatusRow(
                        icon: Icons.check_circle_rounded,
                        color: Colors.greenAccent,
                        message: 'Profile picture updated successfully!',
                      ),
                    if (_errorMessage != null)
                      _StatusRow(
                        icon: Icons.error_outline_rounded,
                        color: AppColors.error,
                        message: _errorMessage!,
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _selectedImageBytes != null
                  ? AppColors.primary
                  : AppColors.line,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 70,
            backgroundColor: AppColors.muted,
            child: _selectedImageBytes != null
                ? ClipOval(
                    child: Image.memory(
                      _selectedImageBytes!,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.person_outline,
                    size: 72,
                    color: AppColors.placeholder,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        CustomText(
          text: _selectedImageBytes != null
              ? 'Preview Ready'
              : 'Current Profile Picture',
          type: CustomTextType.bodyBold,
          color: AppColors.text,
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _StatusRow({
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        CustomText(text: message, type: CustomTextType.body, color: color),
      ],
    );
  }
}
