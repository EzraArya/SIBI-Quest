import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';

class AppBanner extends StatelessWidget {
  final String section;
  final String title;

  const AppBanner({super.key, required this.section, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: section,
            type: CustomTextType.body,
            color: AppColors.text,
          ),
          const SizedBox(height: 6),
          CustomText(
            text: title,
            type: CustomTextType.title,
            color: AppColors.text,
          ),
        ],
      ),
    );
  }
}
