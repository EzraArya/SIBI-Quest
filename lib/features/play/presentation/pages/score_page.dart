import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/widgets/action_button.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';

class ScorePage extends StatefulWidget {
  final int score;
  final String? levelId;

  const ScorePage({super.key, required this.score, this.levelId});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  String get _getScoreMessage {
    if (widget.score >= 80) {
      return "Luar biasa!";
    } else if (widget.score >= 60) {
      return "Kerja bagus!";
    } else if (widget.score >= 40) {
      return "Terus berlatih, ya!";
    } else {
      return "Coba lagi, yuk!";
    }
  }

  String get _getScoreEmoji {
    if (widget.score >= 80) {
      return "🎉";
    } else if (widget.score >= 60) {
      return "👏";
    } else if (widget.score >= 40) {
      return "💪";
    } else {
      return "📚";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Score emoji
              CustomText(
                text: _getScoreEmoji,
                type: CustomTextType.display,
                color: AppColors.text,
              ),

              const SizedBox(height: 24),

              // Score message
              CustomText(
                text: _getScoreMessage,
                type: CustomTextType.title,
                color: AppColors.text,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Score display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Column(
                  children: [
                    const CustomText(
                      text: "Skormu",
                      type: CustomTextType.body,
                      color: AppColors.text,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      text: "${widget.score}",
                      type: CustomTextType.display,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Action buttons
              Column(
                children: [
                  // Play Again button
                  SizedBox(
                    width: double.infinity,
                    child: ActionButton(
                      label: "Main Lagi",
                      type: ButtonType.primary,
                      onPressed: () {
                        // Navigate back to loading/play screen
                        context.go(
                          '/loading?levelId=${widget.levelId ?? "default"}',
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Back to Home button
                  SizedBox(
                    width: double.infinity,
                    child: ActionButton(
                      label: "Back to Home",
                      type: ButtonType.secondary,
                      onPressed: () {
                        context.go('/dashboard/home');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
