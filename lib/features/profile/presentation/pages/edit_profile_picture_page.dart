import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/action_button.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';

class EditProfilePicturePage extends StatefulWidget {
  const EditProfilePicturePage({super.key});

  @override
  State<EditProfilePicturePage> createState() => _EditProfilePicturePageState();
}

class _EditProfilePicturePageState extends State<EditProfilePicturePage> {
  bool _hasSelectedImage = false;
  bool _isUploading = false;
  bool _uploadSuccess = false;
  String? _errorMessage;

  void _navigateBack() {
    context.pop();
  }

  void _handleSelectPhoto() {
    setState(() {
      _hasSelectedImage = true;
      _uploadSuccess = false;
      _errorMessage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image picker coming soon. Using sample preview.'),
      ),
    );
  }

  Future<void> _handleUpload() async {
    if (!_hasSelectedImage) {
      setState(() {
        _errorMessage = 'Please select a photo before uploading.';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
      _uploadSuccess = false;
    });

    // TODO: Hook into real upload flow.
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _isUploading = false;
      _uploadSuccess = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture updated successfully.')),
    );
  }

  void _clearSelection() {
    setState(() {
      _hasSelectedImage = false;
      _uploadSuccess = false;
      _errorMessage = null;
    });
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
                    if (_hasSelectedImage)
                      SizedBox(
                        width: double.infinity,
                        child: ActionButton(
                          label: _isUploading
                              ? 'Uploading...'
                              : 'Update Profile Picture',
                          isLoading: _isUploading,
                          onPressed: () => _handleUpload(),
                          type: ButtonType.primary,
                        ),
                      ),
                    if (_hasSelectedImage) ...[
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
                    if (_isUploading)
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
              color: _hasSelectedImage ? AppColors.primary : AppColors.line,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 70,
            backgroundColor: AppColors.muted,
            child: _hasSelectedImage
                ? const Icon(Icons.person, size: 72, color: AppColors.text)
                : const Icon(
                    Icons.person_outline,
                    size: 72,
                    color: AppColors.placeholder,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        CustomText(
          text: _hasSelectedImage ? 'Preview Ready' : 'Current Profile Picture',
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
