import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/onboarding/presentation/pages/welcome_page.dart';

class OnboardingRoutes {
  static const String homeName = 'home';
  static const String homePath = '/';

  static List<GoRoute> routes() => [
    GoRoute(
      name: homeName,
      path: homePath,
      builder: (context, state) => const WelcomePage(),
    ),
  ];
}
