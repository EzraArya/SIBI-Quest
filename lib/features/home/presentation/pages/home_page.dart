import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/banner.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/widgets/level_button.dart';
import 'package:sibi_quest/features/home/domain/models/level.dart';
import 'package:sibi_quest/features/play/play_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<String?> activePopupNotifier = ValueNotifier<String?>(
    null,
  );

  // Sample levels data - this will be replaced with actual data from repository/API
  late final List<Level> levels;

  @override
  void initState() {
    super.initState();
    levels = _generateSampleLevels();
  }

  @override
  void dispose() {
    activePopupNotifier.dispose();
    super.dispose();
  }

  List<Level> _generateSampleLevels() {
    return [
      const Level(
        id: "level_1",
        title: "Alphabet - 1",
        description: "Basic Alphabet 1",
        minScore: 80,
        number: 1,
        sectionId: "vcknEfQBteeOBs8B5IV1",
        status: LevelStatus.available,
      ),
      const Level(
        id: "level_2",
        title: "Alphabet - 2",
        description: "Basic Alphabet 2",
        minScore: 85,
        number: 2,
        sectionId: "vcknEfQBteeOBs8B5IV1",
        status: LevelStatus.locked,
      ),
      const Level(
        id: "level_3",
        title: "Alphabet - 3",
        description: "Basic Alphabet 3",
        minScore: 90,
        number: 3,
        sectionId: "vcknEfQBteeOBs8B5IV1",
        status: LevelStatus.locked,
      ),
      const Level(
        id: "level_4",
        title: "Alphabet - 4",
        description: "Basic Alphabet 4",
        minScore: 100,
        number: 4,
        sectionId: "vcknEfQBteeOBs8B5IV1",
        status: LevelStatus.locked,
      ),
      const Level(
        id: "level_5",
        title: "Alphabet - 5",
        description: "Basic Alphabet 5",
        minScore: 100,
        number: 5,
        sectionId: "vcknEfQBteeOBs8B5IV1",
        status: LevelStatus.locked,
      ),
    ];
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
          queryParameters: {'levelId': 'level_${level.number}'},
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CustomText(
                    text: "Welcome, ",
                    type: CustomTextType.title,
                    color: AppColors.text,
                  ),
                  CustomText(
                    text: "User",
                    type: CustomTextType.title,
                    color: AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const AppBanner(section: "Section 1", title: "Alphabet"),
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
              // Dynamic level buttons generated from levels array
              Column(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
