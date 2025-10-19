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
        Row(
          children: const [
            CustomText(
              text: "Select the correct",
              type: CustomTextType.title,
              color: AppColors.text,
            ),
            SizedBox(width: 8),
            CustomText(
              text: "Gesture",
              type: CustomTextType.title,
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: CustomText(
            text: promptText,
            type: CustomTextType.display,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 36),
        Expanded(child: _buildImageAnswerGrid()),
      ],
    );
  }

  Widget _buildImageAnswerGrid() {
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
              color: isSelected ? AppColors.primary : AppColors.background,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.line,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
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
        );
      },
    );
  }
}
