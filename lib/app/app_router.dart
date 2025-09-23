import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/onboarding/onboarding_router.dart';
import 'package:sibi_quest/features/auth/auth_router.dart';
import 'package:sibi_quest/features/dashboard/dashboard_router.dart';
import 'package:sibi_quest/features/play/play_router.dart';

// Central app router. Add feature routes here or via sub-routers in the future.
final appRouter = GoRouter(
  initialLocation: OnboardingRoutes.welcomePath,
  routes: [
    ...OnboardingRoutes.routes(),
    ...AuthRoutes.routes(),
    ...DashboardRoutes.routes(),
    ...PlayRoutes.routes()
  ],
);
