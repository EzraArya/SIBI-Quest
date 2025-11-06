import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/features/home/domain/models/level.dart'
    as home_level;
import 'package:sibi_quest/features/play/domain/models/questions.dart';
import 'package:sibi_quest/features/play/domain/services/classifier_service.dart';
import 'package:sibi_quest/features/play/data/static_questions_service.dart';
import 'package:sibi_quest/features/play/presentation/providers/play_providers.dart';
import 'package:sibi_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:sibi_quest/features/play/presentation/pages/type/play_type_one_page.dart';
import 'package:sibi_quest/features/play/presentation/pages/type/play_type_two_page.dart';
import 'package:sibi_quest/features/play/presentation/pages/type/play_type_three_page.dart';
import 'package:sibi_quest/shared/widgets/answer_feedback_section.dart';
import 'package:sibi_quest/shared/utils/image_url_validator.dart';

class PlayPage extends ConsumerStatefulWidget {
  final String? levelId;

  const PlayPage({super.key, this.levelId});

  @override
  ConsumerState<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends ConsumerState<PlayPage> {
  final ClassifierService _classifierService = ClassifierService();

  // Game state
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  Question? get currentQuestion =>
      questions.isNotEmpty ? questions[currentQuestionIndex] : null;

  home_level.Level? _activeLevel;

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
  bool isDetectingGesture = false;
  bool? _pendingGestureMatch;

  @override
  void initState() {
    super.initState();
    unawaited(_loadGameData());
    _initializeClassifier();
  }

  Future<void> _loadGameData() async {
    setState(() {
      questions = [];
      currentQuestionIndex = 0;
      score = 0;
      _resetQuestionState();
      _activeLevel = null;
    });

    final levelId = widget.levelId;
    if (levelId == null || levelId.isEmpty) {
      setState(() {
        questions = StaticQuestionsService.getQuestionsForLevel(levelId);
        currentQuestionIndex = 0;
        score = 0;
        _resetQuestionState();
      });
      return;
    }

    try {
      home_level.Level? levelMetadata;
      try {
        levelMetadata = await ref.read(playLevelProvider(levelId).future);
      } catch (error, stackTrace) {
        debugPrint(
          'Failed to load level metadata for $levelId: $error\n$stackTrace',
        );
        levelMetadata = null;
      }

      final fetchedQuestions = await ref.read(
        playQuestionsProvider(levelId).future,
      );

      if (!mounted) return;

      if (fetchedQuestions.isEmpty) {
        setState(() {
          questions = StaticQuestionsService.getQuestionsForLevel(levelId);
          currentQuestionIndex = 0;
          score = 0;
          _resetQuestionState();
          _activeLevel = levelMetadata;
        });
        return;
      }

      setState(() {
        questions = fetchedQuestions;
        currentQuestionIndex = 0;
        score = 0;
        _resetQuestionState();
        _activeLevel = levelMetadata;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to load questions for level $levelId: $error\n$stackTrace',
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load level from the cloud. Using offline questions.',
          ),
        ),
      );

      setState(() {
        questions = StaticQuestionsService.getQuestionsForLevel(levelId);
        currentQuestionIndex = 0;
        score = 0;
        _resetQuestionState();
        _activeLevel = null;
      });
    }
  }

  void _resetQuestionState() {
    selectedAnswerIndex = null;
    isAnswerCorrect = null;
    isVerified = false;
    selectedImage = null;
    isDetectingGesture = false;
    attemptsUsed = 0;
    _pendingGestureMatch = null;
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

  Future<void> _initializeClassifier() async {
    try {
      await _classifierService.init();
    } catch (error, stackTrace) {
      debugPrint('Classifier initialization error: $error\n$stackTrace');
    }
  }

  Future<void> _handleGestureImageChanged(String? imagePath) async {
    if (!mounted) return;

    setState(() {
      selectedImage = imagePath;
      _pendingGestureMatch = null;
      isDetectingGesture = imagePath != null;
      selectedAnswerIndex = null;
      isAnswerCorrect = null;
      isVerified = false;
    });

    if (imagePath == null) {
      return;
    }

    try {
      final result = await _classifierService.predict(imagePath);
      if (!mounted) return;

      if (result.isFallback) {
        setState(() {
          _pendingGestureMatch = null;
          selectedAnswerIndex = null;
          isDetectingGesture = false;
        });
        return;
      }

      final rawDetectedLabel = result.label.trim();
      final expectedLabel = (currentQuestion?.content.prompt ?? '').trim();

      final detectedLabel = rawDetectedLabel.isEmpty
          ? 'Unknown'
          : rawDetectedLabel;

      final matchesPrompt = _isGestureMatch(
        detectedLabel: detectedLabel,
        expectedLabel: expectedLabel,
        confidence: result.confidence,
      );

      setState(() {
        _pendingGestureMatch = matchesPrompt;
        selectedAnswerIndex = 0;
        isDetectingGesture = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Gesture detection failed: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _pendingGestureMatch = null;
        selectedAnswerIndex = null;
        isDetectingGesture = false;
      });
    }
  }

  void _handleAnswerButtonTap() {
    if (currentQuestion == null) return;

    if (!isVerified && selectedAnswerIndex != null) {
      // Verify answer
      bool isCorrect;
      if (currentQuestion!.type == QuestionType.performGesture) {
        final detection = _pendingGestureMatch;
        if (detection == null) {
          return;
        }
        isCorrect = detection;
      } else {
        isCorrect = currentQuestion!.isCorrectAnswer(selectedAnswerIndex!);
      }
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
            if (currentQuestion!.type == QuestionType.performGesture) {
              selectedAnswerIndex = null;
              _pendingGestureMatch = null;
            } else {
              selectedAnswerIndex = null;
            }
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
      unawaited(_navigateToScore());
    }
  }

  Future<void> _navigateToScore() async {
    final levelId = widget.levelId ?? 'default';
    await _submitProgress(levelId: levelId);
    if (!mounted) return;

    final encodedLevelId = Uri.encodeComponent(levelId);
    final encodedScore = Uri.encodeComponent(score.toString());
    context.go('/score?score=$encodedScore&levelId=$encodedLevelId');
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

  /// Check if detected gesture matches expected label.
  /// Handles special cases: O/0 → O_0, V/2 → V_2
  bool _isGestureMatch({
    required String detectedLabel,
    required String expectedLabel,
    required double confidence,
  }) {
    if (detectedLabel.isEmpty || expectedLabel.isEmpty) {
      return false;
    }

    if (confidence < 0.3) {
      return false;
    }

    final detected = detectedLabel.toUpperCase().trim();
    final expected = expectedLabel.toUpperCase().trim();

    // Direct match
    if (detected == expected) {
      return true;
    }

    // Handle O/0 → O_0
    if ((expected == 'O' || expected == '0') && detected == 'O_0') {
      return true;
    }
    if (expected == 'O_0' && (detected == 'O' || detected == '0')) {
      return true;
    }

    // Handle V/2 → V_2
    if ((expected == 'V' || expected == '2') && detected == 'V_2') {
      return true;
    }
    if (expected == 'V_2' && (detected == 'V' || detected == '2')) {
      return true;
    }

    return false;
  }

  String _getButtonText() {
    if (!isVerified) {
      return 'Kirim Jawaban';
    } else if (isAnswerCorrect == true) {
      if (currentQuestionIndex < questions.length - 1) {
        return 'Pertanyaan Selanjutnya';
      } else {
        return 'Selesaikan Permainan';
      }
    } else {
      final remaining = _maxAttempts - attemptsUsed;
      if (remaining > 0) {
        return 'Coba Lagi';
      }
      return currentQuestionIndex < questions.length - 1
          ? 'Lanjutkan'
          : 'Selesaikan Permainan';
    }
  }

  String? _getHelperText() {
    if (isVerified && isAnswerCorrect != true) {
      final remaining = _maxAttempts - attemptsUsed;
      if (remaining > 0) {
        return '$remaining kesempatan tersisa';
      }
      return 'Tidak ada kesempatan tersisa.';
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
              text: 'Pengaturan Permainan',
              type: CustomTextType.title,
              color: AppColors.text,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.home, color: AppColors.primary),
              title: const CustomText(
                text: 'Kembali ke Beranda',
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
                text: 'Ulangi Level',
                type: CustomTextType.body,
              ),
              onTap: () {
                Navigator.pop(context);
                unawaited(_loadGameData());
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

  Future<void> _submitProgress({required String levelId}) async {
    final user = ref.read(currentUserProvider);
    final userId = user?.id;
    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      await ref
          .read(playProgressControllerProvider.notifier)
          .updateProgress(
            userId: userId,
            levelId: levelId,
            score: score,
            level: _activeLevel,
          );
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to sync progress for level $levelId: $error\n$stackTrace',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kami akan mencoba menyinkronkan progresmu nanti.'),
        ),
      );
    }
  }

  Widget _buildQuestionContent() {
    switch (currentQuestion!.type) {
      case QuestionType.selectAlphabet:
        final promptImage = _resolvePromptImage(currentQuestion!);
        return PlayTypeOnePage(
          promptImage: promptImage,
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
          isProcessing: isDetectingGesture,
          onImageChanged: _handleGestureImageChanged,
        );
    }
  }

  String? _resolvePromptImage(Question question) {
    final content = question.content;
    final candidates = <String?>[];

    final exampleImage = content.exampleImage?.trim();
    if (exampleImage != null && exampleImage.isNotEmpty) {
      candidates.add(exampleImage);
    }

    final prompt = content.prompt.trim();
    if (content.isPromptImage) {
      candidates.add(prompt);
    } else if (isValidNetworkImageUrl(prompt)) {
      candidates.add(prompt);
    }

    for (final candidate in candidates) {
      if (isValidNetworkImageUrl(candidate)) {
        return candidate;
      }
    }

    return null;
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
