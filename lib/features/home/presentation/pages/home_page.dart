import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/banner.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/widgets/level_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<String?> activePopupNotifier = ValueNotifier<String?>(
    null,
  );

  @override
  void dispose() {
    activePopupNotifier.dispose();
    super.dispose();
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
                  CustomText(text: "Welcome, ", type: CustomTextType.title, color: AppColors.text,),
                  CustomText(text: "User", type: CustomTextType.title, color: AppColors.accent,)
                ],
              ),
              const SizedBox(height: 24,),
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
              // Level buttons in a vertical column
              Column(
                children: [
                  LevelButton(
                    level: "1",
                    style: LevelButtonStyle.completed,
                    title: "Level 1",
                    subtitle: "Basic A-Z signs",
                    activePopupNotifier: activePopupNotifier,
                    action: () {
                      print("Starting Level 1");
                    },
                  ),
                  const SizedBox(height: 30),
                  LevelButton(
                    level: "2",
                    style: LevelButtonStyle.completed,
                    title: "Level 2",
                    subtitle: "Common words",
                    activePopupNotifier: activePopupNotifier,
                    action: () {
                      print("Starting Level 2");
                    },
                  ),
                  const SizedBox(height: 30),
                  LevelButton(
                    level: "3",
                    style: LevelButtonStyle.defaultStyle,
                    title: "Level 3",
                    subtitle: "Simple sentences",
                    activePopupNotifier: activePopupNotifier,
                    action: () {
                      print("Starting Level 3");
                    },
                  ),
                  const SizedBox(height: 30),
                  LevelButton(
                    level: "4",
                    style: LevelButtonStyle.locked,
                    title: "Level 4",
                    subtitle: "Complex conversations",
                    activePopupNotifier: activePopupNotifier,
                    action: () {
                      print("Starting Level 4");
                    },
                  ),
                  const SizedBox(height: 30),
                  LevelButton(
                    level: "5",
                    style: LevelButtonStyle.locked,
                    title: "Level 5",
                    subtitle: "Advanced expressions",
                    activePopupNotifier: activePopupNotifier,
                    action: () {
                      print("Starting Level 5");
                    },
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
