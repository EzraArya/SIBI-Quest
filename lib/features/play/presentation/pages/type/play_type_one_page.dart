import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';

class PlayTypeOnePage extends StatelessWidget {
  final String promptImage;
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
        // Title
        Row(
          children: [
            const CustomText(
              text: "Select the correct",
              type: CustomTextType.title,
              color: AppColors.text,
            ),
            const SizedBox(width: 8),
            const CustomText(
              text: "Alphabet",
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
              // Prompt image fetched from remote URL
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 96,
                  height: 96,
                  color: AppColors.muted,
                  child: Image.network(
                    promptImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) => Icon(
                      Icons.broken_image,
                      color: AppColors.secondary,
                      size: 36,
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }
                      return const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Answer grid
              _buildAnswerGrid(),
            ],
          ),
        ),

        const Spacer(),
        const Spacer(),
      ],
    );
  }

  Widget _buildAnswerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
              color: isSelected ? AppColors.primary : AppColors.background,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.line,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: AppColors.muted,
                  child: Image.network(
                    answerOptions[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) => Icon(
                      Icons.broken_image,
                      color: isSelected ? Colors.white : AppColors.secondary,
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }
                      return const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
