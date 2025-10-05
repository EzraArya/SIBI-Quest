import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';

enum AnswerFeedbackState { disabled, idle, correct, incorrect }

class AnswerFeedbackSection extends StatelessWidget {
  const AnswerFeedbackSection({
    super.key,
    required this.state,
    required this.buttonLabel,
    required this.onPressed,
    this.helperText,
  });

  final AnswerFeedbackState state;
  final String buttonLabel;
  final VoidCallback onPressed;
  final String? helperText;

  bool get _isEnabled => state != AnswerFeedbackState.disabled;
  bool get _showStatus =>
      state == AnswerFeedbackState.correct ||
      state == AnswerFeedbackState.incorrect;

  Color get _containerColor {
    switch (state) {
      case AnswerFeedbackState.correct:
        return AppColors.complementary.withValues(alpha: 0.16);
      case AnswerFeedbackState.incorrect:
        return AppColors.error.withValues(alpha: 0.12);
      case AnswerFeedbackState.idle:
        return AppColors.textbox.withValues(alpha: 0);
      case AnswerFeedbackState.disabled:
        return AppColors.textbox.withValues(alpha: 0);
    }
  }

  Color get _borderColor {
    switch (state) {
      case AnswerFeedbackState.correct:
        return AppColors.complementary.withValues(alpha: 0.7);
      case AnswerFeedbackState.incorrect:
        return AppColors.error.withValues(alpha: 0.7);
      case AnswerFeedbackState.idle:
        return AppColors.line.withValues(alpha: 0);
      case AnswerFeedbackState.disabled:
        return AppColors.line.withValues(alpha: 0);
    }
  }

  IconData? get _statusIcon {
    switch (state) {
      case AnswerFeedbackState.correct:
        return Icons.check_circle_rounded;
      case AnswerFeedbackState.incorrect:
        return Icons.cancel_rounded;
      case AnswerFeedbackState.idle:
      case AnswerFeedbackState.disabled:
        return null;
    }
  }

  Color get _statusColor {
    switch (state) {
      case AnswerFeedbackState.correct:
        return AppColors.complementary;
      case AnswerFeedbackState.incorrect:
        return AppColors.error;
      case AnswerFeedbackState.idle:
      case AnswerFeedbackState.disabled:
        return AppColors.placeholder;
    }
  }

  String get _statusText {
    switch (state) {
      case AnswerFeedbackState.correct:
        return 'Correct';
      case AnswerFeedbackState.incorrect:
        return 'Incorrect';
      case AnswerFeedbackState.idle:
      case AnswerFeedbackState.disabled:
        return '';
    }
  }

  Color get _buttonColor {
    switch (state) {
      case AnswerFeedbackState.correct:
        return AppColors.complementary;
      case AnswerFeedbackState.incorrect:
        return AppColors.error;
      case AnswerFeedbackState.idle:
        return AppColors.primary;
      case AnswerFeedbackState.disabled:
        return AppColors.muted;
    }
  }

  Color get _buttonForeground {
    switch (state) {
      case AnswerFeedbackState.disabled:
        return AppColors.placeholder;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: _containerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showStatus) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_statusIcon != null)
                  Icon(_statusIcon, color: _statusColor, size: 24),
                if (_statusIcon != null) const SizedBox(width: 12),
                CustomText(
                  text: _statusText,
                  type: CustomTextType.title,
                  color: _statusColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (helperText != null && helperText!.isNotEmpty) ...[
            CustomText(
              text: helperText!,
              type: CustomTextType.body,
              color: AppColors.placeholder,
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isEnabled ? onPressed : null,
              style: FilledButton.styleFrom(
                backgroundColor: _buttonColor,
                foregroundColor: _buttonForeground,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: CustomText(
                text: buttonLabel,
                type: CustomTextType.bodyBold,
                color: _buttonForeground,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
