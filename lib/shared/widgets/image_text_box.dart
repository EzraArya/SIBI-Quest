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
  final Color backgroundColor;
  final Color titleColor;
  final Color descriptionColor;
  final CustomTextType titleType;
  final CustomTextType descriptionType;
  final int descriptionMaxLines;
  final double spacing;

  const ImageTextBox({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.padding = const EdgeInsets.all(12),
    this.borderColor = AppColors.primary,
    this.borderWidth = 2,
    this.borderRadius = 6,
    this.backgroundColor = Colors.transparent,
    this.titleColor = AppColors.text,
    this.descriptionColor = AppColors.text,
    this.titleType = CustomTextType.bodyBold,
    this.descriptionType = CustomTextType.text,
    this.descriptionMaxLines = 2,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(text: title, type: titleType, color: titleColor),
                const SizedBox(height: 2),
                CustomText(
                  text: description,
                  type: descriptionType,
                  color: descriptionColor,
                  maxLines: descriptionMaxLines,
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
