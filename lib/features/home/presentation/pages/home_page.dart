import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:sibi_quest/features/home/presentation/providers/home_providers.dart';
import 'package:sibi_quest/cores/models/section.dart' as core_section;
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
      return 'Penjelajah';
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
                    text: 'Selamat Datang, ',
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
                data: (sections) => _SectionsContent(
                  sections: sections,
                  levelsAsync: levelsAsync,
                  onLevelTap: _onLevelTap,
                  activePopupNotifier: activePopupNotifier,
                  mapLevelStatusToStyle: _mapLevelStatusToButtonStyle,
                  onRetryLevels: () {
                    ref.invalidate(homeLevelsProvider);
                  },
                ),
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => _SectionsError(
                  onRetry: () {
                    ref.invalidate(sectionsProvider);
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

class _SectionsContent extends StatelessWidget {
  const _SectionsContent({
    required this.sections,
    required this.levelsAsync,
    required this.onLevelTap,
    required this.activePopupNotifier,
    required this.mapLevelStatusToStyle,
    required this.onRetryLevels,
  });

  final List<core_section.Section> sections;
  final AsyncValue<List<Level>> levelsAsync;
  final void Function(Level) onLevelTap;
  final ValueNotifier<String?> activePopupNotifier;
  final LevelButtonStyle Function(LevelStatus) mapLevelStatusToStyle;
  final VoidCallback onRetryLevels;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const CustomText(
        text: 'No sections available yet',
        type: CustomTextType.body,
        color: AppColors.text,
      );
    }

    final sortedSections = [...sections]
      ..sort((a, b) => a.number.compareTo(b.number));

    return levelsAsync.when(
      data: (levels) {
        final levelsBySection = <String, List<Level>>{};
        for (final level in levels) {
          levelsBySection.putIfAbsent(level.sectionId, () => []).add(level);
        }

        List<Level> levelsForSection(core_section.Section section) {
          final sectionId = section.id;
          if (sectionId != null && sectionId.isNotEmpty) {
            final match = levelsBySection[sectionId];
            if (match != null) {
              return match;
            }
          }

          return levelsBySection['section_${section.number}'] ??
              const <Level>[];
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < sortedSections.length; index++) ...[
              _SectionBlock(
                section: sortedSections[index],
                levels: levelsForSection(sortedSections[index]),
                onLevelTap: onLevelTap,
                activePopupNotifier: activePopupNotifier,
                mapLevelStatusToStyle: mapLevelStatusToStyle,
              ),
              if (index != sortedSections.length - 1)
                const SizedBox(height: 24),
            ],
          ],
        );
      },
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _LevelsError(onRetry: onRetryLevels),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.section,
    required this.levels,
    required this.onLevelTap,
    required this.activePopupNotifier,
    required this.mapLevelStatusToStyle,
  });

  final core_section.Section section;
  final List<Level> levels;
  final void Function(Level) onLevelTap;
  final ValueNotifier<String?> activePopupNotifier;
  final LevelButtonStyle Function(LevelStatus) mapLevelStatusToStyle;

  @override
  Widget build(BuildContext context) {
    final sortedLevels = [...levels]
      ..sort((a, b) => a.number.compareTo(b.number));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBanner(
          section: section.displayName,
          title: section.title,
        ),
        const SizedBox(height: 16),
        if (sortedLevels.isEmpty)
          const CustomText(
            text: 'Levels will appear here soon!',
            type: CustomTextType.body,
            color: AppColors.text,
          )
        else
          Column(
            children: [
              for (final level in sortedLevels) ...[
                LevelButton(
                  level: level.number.toString(),
                  identifier: level.id,
                  style: mapLevelStatusToStyle(level.status),
                  title: level.title,
                  subtitle: level.description,
                  activePopupNotifier: activePopupNotifier,
                  action: () => onLevelTap(level),
                ),
                if (level != sortedLevels.last) const SizedBox(height: 30),
              ],
            ],
          ),
      ],
    );
  }
}

class _SectionsError extends StatelessWidget {
  const _SectionsError({required this.onRetry});

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
