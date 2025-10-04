import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/features/play/domain/models/questions.dart';
import 'package:sibi_quest/features/play/domain/services/yolo_service.dart';
import 'package:sibi_quest/features/play/data/static_questions_service.dart';
import 'package:sibi_quest/features/play/presentation/pages/type/play_type_one_page.dart';
import 'package:sibi_quest/features/play/presentation/pages/type/play_type_two_page.dart';
import 'package:sibi_quest/features/play/presentation/pages/type/play_type_three_page.dart';
import 'package:sibi_quest/shared/widgets/answer_feedback_section.dart';

class PlayPage extends StatefulWidget {
  final String? levelId;

  const PlayPage({super.key, this.levelId});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  final YoloService _yoloService = YoloService();

  // Game state
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  Question? get currentQuestion =>
      questions.isNotEmpty ? questions[currentQuestionIndex] : null;

  double get progressValue {
    if (questions.isEmpty) {
      return 0.0;
    }

    final completed = currentQuestionIndex;
    final clearedCurrent = isVerified && isAnswerCorrect == true ? 1 : 0;
    final totalCompleted = (completed + clearedCurrent).clamp(
      0,
      questions.length,
    );

    return (totalCompleted / questions.length).clamp(0.0, 1.0);
  }

  double get progressPercentage => progressValue * 100;

  int? selectedAnswerIndex;
  bool? isAnswerCorrect;
  bool isVerified = false;
  int score = 0;
  static const int _maxAttempts = 3;
  int attemptsUsed = 0;

  String? selectedImage;
  String? gestureLabel;
  double? gestureConfidence;
  bool isDetectingGesture = false;

  @override
  void initState() {
    super.initState();
    _loadGameData();
    _initializeYolo();
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
    gestureConfidence = null;
    isDetectingGesture = false;
    attemptsUsed = 0;
  }

  void _onAnswerSelected(int index) {
    if (isVerified) {
      HapticFeedback.mediumImpact();
      return;
    }

    if (selectedAnswerIndex != index) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      selectedAnswerIndex = index;
      isAnswerCorrect = null;
    });
  }

  Future<void> _initializeYolo() async {
    try {
      await _yoloService.init();
    } catch (error, stackTrace) {
      debugPrint('YOLO initialization error: $error\n$stackTrace');
    }
  }

  Future<void> _handleGestureImageChanged(String? imagePath) async {
    if (!mounted) return;

    setState(() {
      selectedImage = imagePath;
      gestureLabel = null;
      gestureConfidence = null;
      isDetectingGesture = imagePath != null;
      selectedAnswerIndex = null;
      isAnswerCorrect = null;
      isVerified = false;
    });

    if (imagePath == null) {
      return;
    }

    try {
      final result = await _yoloService.predict(imagePath);
      if (!mounted) return;

      if (result.isFallback) {
        setState(() {
          gestureLabel = result.gestureLabel;
          gestureConfidence = result.confidence;
          selectedAnswerIndex = 0;
          isDetectingGesture = false;
        });
        return;
      }

      final rawDetectedLabel = result.gestureLabel.trim();
      final expectedLabel = (currentQuestion?.content.prompt ?? '').trim();

      final detectedLabel = rawDetectedLabel.isEmpty
          ? 'Unknown'
          : rawDetectedLabel;

      final matchesPrompt =
          detectedLabel.isNotEmpty &&
          expectedLabel.isNotEmpty &&
          detectedLabel.toUpperCase() == expectedLabel.toUpperCase() &&
          result.confidence >= 0.3;

      setState(() {
        gestureLabel = detectedLabel;
        gestureConfidence = result.confidence;
        selectedAnswerIndex = matchesPrompt ? 0 : null;
        isDetectingGesture = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Gesture detection failed: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        gestureLabel = 'Detected Gesture';
        gestureConfidence = null;
        selectedAnswerIndex = 0;
        isDetectingGesture = false;
      });
    }
  }

  void _handleAnswerButtonTap() {
    if (currentQuestion == null) return;

    if (!isVerified && selectedAnswerIndex != null) {
      // Verify answer
      final isCorrect = currentQuestion!.isCorrectAnswer(selectedAnswerIndex!);
      final nextAttempts = attemptsUsed + 1;
      setState(() {
        attemptsUsed = nextAttempts;
        isAnswerCorrect = isCorrect;
        isVerified = true;
        if (isCorrect) {
          score += 10; // Add points for correct answer
        }
      });
      if (!isCorrect) {
        final remaining = _maxAttempts - nextAttempts;
        if (remaining > 0) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.heavyImpact();
        }
      }
    } else if (isVerified) {
      if (isAnswerCorrect == true) {
        _advanceToNextQuestion();
      } else {
        if (attemptsUsed >= _maxAttempts) {
          _advanceToNextQuestion();
        } else {
          HapticFeedback.selectionClick();
          setState(() {
            isVerified = false;
            isAnswerCorrect = null;
            selectedAnswerIndex = null;
          });
        }
      }
    }
  }

  void _advanceToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        _resetQuestionState();
      });
    } else {
      _navigateToScore();
    }
  }

  void _navigateToScore() {
    // Navigate to score page with final score
    context.go('/score?score=$score&levelId=${widget.levelId ?? "default"}');
  }

  AnswerFeedbackState _resolveFeedbackState() {
    if (selectedAnswerIndex == null) {
      return AnswerFeedbackState.disabled;
    }

    if (!isVerified) {
      return AnswerFeedbackState.idle;
    }

    return isAnswerCorrect == true
        ? AnswerFeedbackState.correct
        : AnswerFeedbackState.incorrect;
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
      final remaining = _maxAttempts - attemptsUsed;
      if (remaining > 0) {
        return 'Try Again';
      }
      return currentQuestionIndex < questions.length - 1
          ? 'Continue'
          : 'Finish Game';
    }
  }

  String? _getHelperText() {
    if (isVerified && isAnswerCorrect != true) {
      final remaining = _maxAttempts - attemptsUsed;
      if (remaining > 0) {
        final suffix = remaining == 1 ? '' : 's';
        return '$remaining attempt$suffix remaining';
      }
      return 'No attempts remaining.';
    }
    return null;
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
                    child: _AnimatedProgressBar(progress: progressValue),
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
              child: AnswerFeedbackSection(
                state: _resolveFeedbackState(),
                buttonLabel: _getButtonText(),
                helperText: _getHelperText(),
                onPressed: _handleAnswerButtonTap,
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
          selectedIndex: selectedAnswerIndex,
        );
      case QuestionType.selectGesture:
        return PlayTypeTwoPage(
          promptText: currentQuestion!.content.prompt,
          answerOptions: currentQuestion!.content.answers
              .map((a) => a.value)
              .toList(),
          onAnswerSelected: _onAnswerSelected,
          selectedIndex: selectedAnswerIndex,
        );
      case QuestionType.performGesture:
        return PlayTypeThreePage(
          promptText: currentQuestion!.content.prompt,
          selectedImage: selectedImage,
          gestureLabel: gestureLabel,
          gestureConfidence: gestureConfidence,
          isProcessing: isDetectingGesture,
          onImageChanged: _handleGestureImageChanged,
        );
    }
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final clampedProgress = progress.clamp(0.0, 1.0);
        final targetWidth = constraints.maxWidth * clampedProgress;

        return SizedBox(
          height: 12,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: targetWidth,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
