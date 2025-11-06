import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/custom_line.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/widgets/action_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CustomText(
                  text: 'Sudah punya akun?',
                  type: CustomTextType.body,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ActionButton(
                    label: 'Masuk',
                    type: ButtonType.primary,
                    onPressed: () {
                      context.go('/login');
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const CustomLine.horizontal(
                  color: AppColors.line,
                  thickness: 1,
                  length: double.infinity,
                ),
                const SizedBox(height: 16),
                const CustomText(
                  text: 'Baru di SIBI Quest?',
                  type: CustomTextType.body,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ActionButton(
                    label: 'Daftar Sekarang',
                    type: ButtonType.secondary,
                    onPressed: () {
                      context.go('/onboarding');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
