import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:sibi_quest/features/home/presentation/providers/home_providers.dart';
import 'package:sibi_quest/features/home/domain/models/level.dart';
import 'package:sibi_quest/features/play/play_router.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/banner.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/widgets/level_button.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ValueNotifier<String?> activePopupNotifier = ValueNotifier<String?>(
    null,
  );

  @override
  void dispose() {
    activePopupNotifier.dispose();
    super.dispose();
  }

  LevelButtonStyle _mapLevelStatusToButtonStyle(LevelStatus status) {
    switch (status) {
      case LevelStatus.completed:
        return LevelButtonStyle.completed;
      case LevelStatus.available:
        return LevelButtonStyle.defaultStyle;
      case LevelStatus.locked:
        return LevelButtonStyle.locked;
    }
  }

  void _onLevelTap(Level level) {
    switch (level.status) {
      case LevelStatus.available:
      case LevelStatus.completed:
        context.pushNamed(
          PlayRoutes.loadingName,
          queryParameters: {'levelId': level.id},
        );
        break;

      case LevelStatus.locked:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text:
                  "${level.title} is locked. Complete previous levels to unlock.",
              type: CustomTextType.body,
              color: Colors.white,
            ),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final sectionsAsync = ref.watch(sectionsProvider);
    final levelsAsync = ref.watch(homeLevelsProvider);

    final displayName = () {
      final rawName = (user?.firstName ?? '').trim();
      if (rawName.isNotEmpty) {
        return rawName;
      }
      return 'Explorer';
    }();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CustomText(
                    text: 'Welcome, ',
                    type: CustomTextType.title,
                    color: AppColors.text,
                  ),
                  CustomText(
                    text: displayName,
                    type: CustomTextType.title,
                    color: AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              sectionsAsync.when(
                data: (sections) {
                  final sorted = [...sections]
                    ..sort((a, b) => a.number.compareTo(b.number));
                  final section = sorted.isNotEmpty ? sorted.first : null;
                  return AppBanner(
                    section: section?.displayName ?? 'Section',
                    title: section?.title ?? 'Discover Levels',
                  );
                },
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => _BannerError(
                  onRetry: () {
                    ref.invalidate(sectionsProvider);
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Levels",
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              levelsAsync.when(
                data: (levels) {
                  if (levels.isEmpty) {
                    return const CustomText(
                      text: 'Levels will appear here soon!',
                      type: CustomTextType.body,
                      color: AppColors.text,
                    );
                  }

                  return Column(
                    children: levels.asMap().entries.map((entry) {
                      final level = entry.value;
                      final isLastLevel = entry.key == levels.length - 1;

                      return Column(
                        children: [
                          LevelButton(
                            level: level.number.toString(),
                            style: _mapLevelStatusToButtonStyle(level.status),
                            title: level.title,
                            subtitle: level.description,
                            activePopupNotifier: activePopupNotifier,
                            action: () => _onLevelTap(level),
                          ),
                          if (!isLastLevel) const SizedBox(height: 30),
                        ],
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _LevelsError(
                  onRetry: () {
                    ref.invalidate(homeLevelsProvider);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerError extends StatelessWidget {
  const _BannerError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: 'Unable to load sections',
          type: CustomTextType.body,
          color: AppColors.text,
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

class _LevelsError extends StatelessWidget {
  const _LevelsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: 'Failed to load levels',
          type: CustomTextType.body,
          color: AppColors.text,
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}
