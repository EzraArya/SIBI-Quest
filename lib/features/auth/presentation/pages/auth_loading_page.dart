import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/dashboard/dashboard_router.dart';
import 'package:sibi_quest/features/home/presentation/providers/home_providers.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';

class AuthLoadingPage extends ConsumerStatefulWidget {
  const AuthLoadingPage({super.key});

  @override
  ConsumerState<AuthLoadingPage> createState() => _AuthLoadingPageState();
}

class _AuthLoadingPageState extends ConsumerState<AuthLoadingPage> {
  @override
  void initState() {
    super.initState();
    // Use post-frame callback to ensure widget tree is built before accessing providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _waitForUserData();
    });
  }

  Future<void> _waitForUserData() async {
    // Invalidate providers to ensure fresh data is fetched
    ref.invalidate(userLevelDataProvider);
    ref.invalidate(homeLevelsProvider);
    
    // Wait 3 seconds for Firestore writes to complete and propagate
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      context.go(DashboardRoutes.homePath);
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
              text: "🎮",
              type: CustomTextType.display,
              color: AppColors.text,
            ),
            const SizedBox(height: 16),
            // Loading text
            const CustomText(
              text: "Menyiapkan akun Anda...",
              type: CustomTextType.title,
              color: AppColors.text,
            ),
            const SizedBox(height: 8),
            const CustomText(
              text: "Mohon tunggu sebentar",
              type: CustomTextType.body,
              color: AppColors.text,
            ),
            const SizedBox(height: 32),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
