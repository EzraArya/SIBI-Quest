import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/play/play_router.dart';

class PlayTypeThreePage extends StatelessWidget {
  final String promptText;
  final String? selectedImage;
  final String? gestureLabel;
  final Function(String?) onImageChanged;

  const PlayTypeThreePage({
    super.key,
    required this.promptText,
    this.selectedImage,
    this.gestureLabel,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            const CustomText(
              text: "Perform this",
              type: CustomTextType.title,
              color: AppColors.text,
            ),
            const SizedBox(width: 8),
            const CustomText(
              text: "Gesture",
              type: CustomTextType.title,
              color: AppColors.primary,
            ),
          ],
        ),

        const Spacer(),

        // Content
        Center(
          child: Column(
            children: [
              // Prompt text (large font)
              CustomText(
                text: promptText,
                type: CustomTextType.display,
                color: AppColors.text,
              ),

              const SizedBox(height: 36),

              // Image display area
              _buildImageArea(),

              // Debug info (if gesture detected)
              if (gestureLabel != null) ...[
                const SizedBox(height: 12),
                _buildDebugInfo(),
              ],
            ],
          ),
        ),

        const Spacer(),

        // Camera button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _showCameraOptions(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.text,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: CustomText(
              text: selectedImage != null ? "Retake Photo" : "Take Photo",
              type: CustomTextType.bodyBold,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageArea() {
    return Container(
      width: 312,
      height: 312,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: selectedImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                color: AppColors.secondary,
                child: Center(
                  child: CustomText(
                    text: "Image Selected",
                    type: CustomTextType.body,
                    color: AppColors.text,
                  ),
                ),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: CustomText(
        text: "Select an image",
        type: CustomTextType.body,
        color: AppColors.accent,
      ),
    );
  }

  Widget _buildDebugInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: gestureLabel ?? '',
            type: CustomTextType.bodyBold,
            color: AppColors.text,
          ),
          const SizedBox(width: 16),
          CustomText(
            text: "85%", // TODO: Implement actual confidence
            type: CustomTextType.body,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _showCameraOptions(BuildContext context) async {
    final result = await context.pushNamed(PlayRoutes.cameraName);
    if (result is String && result.isNotEmpty) {
      onImageChanged(result);
    }
  }
}
