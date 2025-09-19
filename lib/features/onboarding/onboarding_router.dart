import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:sibi_quest/features/onboarding/presentation/pages/onboarding_page.dart';

class OnboardingRoutes {
  static const String welcomeName = 'welcome';
  static const String onboardingName = 'onboarding';
  static const String welcomePath = '/';
  static const String onboardingPath = '/onboarding';

  static List<GoRoute> routes() => [
    GoRoute(
      name: welcomeName,
      path: welcomePath,
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      name: onboardingName,
      path: onboardingPath,
      builder: (context, state) => const OnboardingPage(),
    ),
  ];
}
