import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sibi_quest/shared/utils/image_url_validator.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';

class PlayTypeOnePage extends StatelessWidget {
  final String? promptImage;
  final List<String> answerOptions;
  final ValueChanged<int> onAnswerSelected;
  final int? selectedIndex;

  const PlayTypeOnePage({
    super.key,
    required this.promptImage,
    required this.answerOptions,
    required this.onAnswerSelected,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            CustomText(
              text: "Select the correct",
              type: CustomTextType.title,
              color: AppColors.text,
            ),
            SizedBox(width: 8),
            CustomText(
              text: "Alphabet",
              type: CustomTextType.title,
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(child: _PromptImageTile(imageUrl: promptImage)),
        const SizedBox(height: 36),
        Expanded(child: _buildAnswerGrid()),
      ],
    );
  }

  Widget _buildAnswerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: answerOptions.length,
      itemBuilder: (context, index) {
        final bool isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () => onAnswerSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.textbox,
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.line,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : const [],
            ),
            child: Center(
              child: CustomText(
                text: answerOptions[index],
                type: CustomTextType.title,
                color: isSelected ? Colors.white : AppColors.text,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PromptImageTile extends StatelessWidget {
  const _PromptImageTile({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasValidUrl = isValidNetworkImageUrl(imageUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 96,
        height: 96,
        color: AppColors.muted,
        child: hasValidUrl
            ? CachedNetworkImage(
                key: ValueKey(imageUrl),
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.broken_image,
                  color: AppColors.secondary,
                  size: 36,
                ),
              )
            : Icon(
                Icons.image_not_supported_rounded,
                color: AppColors.secondary,
                size: 36,
              ),
      ),
    );
  }
}
