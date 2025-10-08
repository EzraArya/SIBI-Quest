import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/action_button.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';

class AppAlert extends StatelessWidget {
  final String title;
  final String message;
  final String primaryButtonLabel;
  final String secondaryButtonLabel;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;
  final ButtonType primaryButtonType;
  final ButtonType secondaryButtonType;

  const AppAlert({
    super.key,
    required this.title,
    required this.message,
    required this.primaryButtonLabel,
    required this.secondaryButtonLabel,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    this.primaryButtonType = ButtonType.danger,
    this.secondaryButtonType = ButtonType.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.textbox,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomText(
                text: title,
                type: CustomTextType.title,
                color: AppColors.text,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              CustomText(
                text: message,
                type: CustomTextType.body,
                color: AppColors.placeholder,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ActionButton(
              label: primaryButtonLabel,
              type: primaryButtonType,
              onPressed: onPrimaryPressed,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ActionButton(
              label: secondaryButtonLabel,
              type: secondaryButtonType,
              onPressed: onSecondaryPressed,
            ),
          ),
        ],
      ),
    );
  }
}
