import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/features/play/domain/models/questions.dart';
import 'package:sibi_quest/features/play/data/static_questions_service.dart';
import 'package:sibi_quest/features/play/presentation/pages/type/play_type_one_page.dart';
import 'package:sibi_quest/features/play/presentation/pages/type/play_type_two_page.dart';
import 'package:sibi_quest/features/play/presentation/pages/type/play_type_three_page.dart';

class PlayPage extends StatefulWidget {
  final String? levelId;

  const PlayPage({super.key, this.levelId});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  // Game state
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  Question? get currentQuestion =>
      questions.isNotEmpty ? questions[currentQuestionIndex] : null;

  double get progressPercentage => questions.isNotEmpty
      ? (currentQuestionIndex + 1) / questions.length
      : 0.0;

  int? selectedAnswerIndex;
  bool? isAnswerCorrect;
  bool isVerified = false;
  int score = 0;

  // Camera/gesture data for type three
  String? selectedImage;
  String? gestureLabel;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  void _loadGameData() {
    setState(() {
      questions = StaticQuestionsService.getQuestionsForLevel(widget.levelId);
      currentQuestionIndex = 0;
      score = 0;
      _resetQuestionState();
    });
  }

  void _resetQuestionState() {
    selectedAnswerIndex = null;
    isAnswerCorrect = null;
    isVerified = false;
    selectedImage = null;
    gestureLabel = null;
  }

  void _onAnswerSelected(int index) {
    setState(() {
      selectedAnswerIndex = index;
      isAnswerCorrect = null;
      isVerified = false;
    });
  }

  void _handleAnswerButtonTap() {
    if (currentQuestion == null) return;

    if (!isVerified && selectedAnswerIndex != null) {
      // Verify answer
      final isCorrect = currentQuestion!.isCorrectAnswer(selectedAnswerIndex!);
      setState(() {
        isAnswerCorrect = isCorrect;
        isVerified = true;
        if (isCorrect) {
          score += 10; // Add points for correct answer
        }
      });
    } else if (isVerified) {
      // Move to next question or finish game
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          _resetQuestionState();
        });
      } else {
        // Game finished, navigate to score page
        _navigateToScore();
      }
    }
  }

  void _navigateToScore() {
    // Navigate to score page with final score
    context.go('/score?score=$score&levelId=${widget.levelId ?? "default"}');
  }

  String _getButtonText() {
    if (!isVerified) {
      return 'Submit Answer';
    } else if (isAnswerCorrect == true) {
      if (currentQuestionIndex < questions.length - 1) {
        return 'Next Question';
      } else {
        return 'Finish Game';
      }
    } else {
      return 'Try Again';
    }
  }

  Color _getButtonColor() {
    if (!isVerified) {
      return AppColors.primary;
    } else if (isAnswerCorrect == true) {
      return AppColors.complementary;
    } else {
      return AppColors.error;
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: 'Game Settings',
              type: CustomTextType.title,
              color: AppColors.text,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.home, color: AppColors.primary),
              title: const CustomText(
                text: 'Return to Home',
                type: CustomTextType.body,
              ),
              onTap: () {
                Navigator.pop(context);
                context.go('/dashboard/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.refresh, color: AppColors.primary),
              title: const CustomText(
                text: 'Restart Level',
                type: CustomTextType.body,
              ),
              onTap: () {
                Navigator.pop(context);
                _loadGameData();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with settings and progress
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // Settings button
                  IconButton(
                    onPressed: _showSettings,
                    icon: Icon(
                      Icons.settings,
                      color: AppColors.secondary,
                      weight: 700,
                    ),
                  ),

                  const Spacer(),

                  // Progress bar with question counter
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        CustomText(
                          text:
                              '${currentQuestionIndex + 1}/${questions.length}',
                          type: CustomTextType.body,
                          color: AppColors.text,
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progressPercentage,
                          backgroundColor: AppColors.line,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),

            // Game content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: currentQuestion != null
                    ? _buildQuestionContent()
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),

            // Answer button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedAnswerIndex != null
                      ? _handleAnswerButtonTap
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getButtonColor(),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: CustomText(
                    text: _getButtonText(),
                    type: CustomTextType.bodyBold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    switch (currentQuestion!.type) {
      case QuestionType.selectAlphabet:
        return PlayTypeOnePage(
          promptImage: currentQuestion!.content.prompt,
          answerOptions: currentQuestion!.content.answers
              .map((a) => a.value)
              .toList(),
          onAnswerSelected: _onAnswerSelected,
        );
      case QuestionType.selectGesture:
        return PlayTypeTwoPage(
          promptText: currentQuestion!.content.prompt,
          answerOptions: currentQuestion!.content.answers
              .map((a) => a.value)
              .toList(),
          onAnswerSelected: _onAnswerSelected,
        );
      case QuestionType.performGesture:
        return PlayTypeThreePage(
          promptText: currentQuestion!.content.prompt,
          selectedImage: selectedImage,
          gestureLabel: gestureLabel,
          onImageChanged: (image) {
            setState(() {
              selectedImage = image;
              if (image != null) {
                selectedAnswerIndex = 0; // Simulate gesture detection
                gestureLabel =
                    'Detected Gesture'; // TODO: Implement actual gesture detection
              } else {
                selectedAnswerIndex = null;
                gestureLabel = null;
              }
            });
          },
        );
    }
  }
}
