import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';

class PlayTypeOnePage extends StatelessWidget {
  final String promptImage;
  final List<String> answerOptions;
  final Function(int) onAnswerSelected;

  const PlayTypeOnePage({
    super.key,
    required this.promptImage,
    required this.answerOptions,
    required this.onAnswerSelected,
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
              // Prompt image placeholder
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.gesture,
                    size: 32,
                    color: AppColors.primary,
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
        return GestureDetector(
          onTap: () => onAnswerSelected(index),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.line, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CustomText(
                text: answerOptions[index],
                type: CustomTextType.title,
                color: AppColors.text,
              ),
            ),
          ),
        );
      },
    );
  }
}
