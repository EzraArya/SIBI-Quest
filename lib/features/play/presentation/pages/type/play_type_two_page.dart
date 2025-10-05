import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';

class PlayTypeTwoPage extends StatelessWidget {
  final String promptText;
  final List<String> answerOptions;
  final ValueChanged<int> onAnswerSelected;
  final int? selectedIndex;

  const PlayTypeTwoPage({
    super.key,
    required this.promptText,
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
                color: AppColors.secondary,
              ),

              const SizedBox(height: 36),

              // Answer grid (images)
              _buildImageAnswerGrid(),
            ],
          ),
        ),

        const Spacer(),
        const Spacer(),
      ],
    );
  }

  Widget _buildImageAnswerGrid() {
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image placeholder
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.complementary
                          : AppColors.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.gesture,
                      color: isSelected
                          ? AppColors.background
                          : AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text: answerOptions[index],
                    type: CustomTextType.body,
                    color: isSelected ? Colors.white : AppColors.text,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
