import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/play/play_router.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/action_button.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';

class PlayTypeThreePage extends StatelessWidget {
  final String promptText;
  final String? selectedImage;
  final bool isProcessing;
  final Future<void> Function(String?) onImageChanged;

  const PlayTypeThreePage({
    super.key,
    required this.promptText,
    this.selectedImage,
    this.isProcessing = false,
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
              text: "Lakukan",
              type: CustomTextType.title,
              color: AppColors.text,
            ),
            const SizedBox(width: 8),
            const CustomText(
              text: "Gesture",
              type: CustomTextType.title,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            const CustomText(
              text: "Berikut",
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

              if (isProcessing) ...[
                const SizedBox(height: 12),
                _buildProcessingInfo(),
              ],
            ],
          ),
        ),

        const Spacer(),

        // Camera button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ActionButton(
            label: selectedImage != null ? 'Retake Photo' : 'Take Photo',
            type: ButtonType.secondary,
            isLoading: isProcessing,
            onPressed: () {
              _showCameraOptions(context);
            },
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(selectedImage!), fit: BoxFit.cover),
                  if (isProcessing)
                    Container(
                      color: AppColors.background.withValues(alpha: 0.6),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
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

  Widget _buildProcessingInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          CustomText(
            text: 'Analysing your gesture...',
            type: CustomTextType.body,
            color: AppColors.text,
          ),
        ],
      ),
    );
  }

  Future<void> _showCameraOptions(BuildContext context) async {
    final result = await context.pushNamed(PlayRoutes.cameraName);
    if (result is String && result.isNotEmpty) {
      await onImageChanged(result);
    }
  }
}
