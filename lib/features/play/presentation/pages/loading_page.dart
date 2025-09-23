import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';

class LoadingPage extends StatefulWidget {
  final String? levelId;

  const LoadingPage({super.key, this.levelId});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    // Simulate loading game data
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Navigate to play screen when loading is complete
      if (widget.levelId != null) {
        context.go('/play?levelId=${widget.levelId}');
      } else {
        context.go('/play');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large emoji
            const CustomText(
              text: "😀",
              type: CustomTextType.display,
              color: AppColors.text,
            ),
            const SizedBox(height: 16),
            // Loading text
            const CustomText(
              text: "Loading Game!",
              type: CustomTextType.title,
              color: AppColors.text,
            ),
            const SizedBox(height: 32),
            // Loading indicator
            if (_isLoading)
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
