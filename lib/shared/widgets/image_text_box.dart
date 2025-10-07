import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/app_system_icon.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';

class ImageTextBox extends StatelessWidget {
  final AppSystemIcon icon;
  final String title;
  final String description;
  final EdgeInsets padding;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  const ImageTextBox({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.padding = const EdgeInsets.all(12),
    this.borderColor = AppColors.primary,
    this.borderWidth = 2,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: title,
                  type: CustomTextType.bodyBold,
                  color: AppColors.text,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: description,
                  type: CustomTextType.body,
                  color: AppColors.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
