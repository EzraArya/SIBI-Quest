import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/dashboard/presentation/widgets/dashboard_shell.dart';
import 'package:sibi_quest/features/home/presentation/pages/home_page.dart';
import 'package:sibi_quest/features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:sibi_quest/features/profile/presentation/pages/profile_page.dart';

class DashboardRoutes {
  static const String dashboardPath = '/dashboard';
  static const String homePath = '/dashboard/home';
  static const String leaderboardPath = '/dashboard/leaderboard';
  static const String profilePath = '/dashboard/profile';

  static List<RouteBase> routes() => [
    ShellRoute(
      routes: [
        GoRoute(
          path: homePath,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomePage(),
          ),
        ),
        GoRoute(
          path: leaderboardPath,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LeaderboardPage(),
          ),
        ),
        GoRoute(
          path: profilePath,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfilePage(),
          ),
        ),
      ],
      builder: (context, state, child) {
        // Determine which tab is selected based on current location
        int selectedIndex = 0;
        final location = state.uri.path;
        if (location.startsWith('/dashboard/leaderboard')) {
          selectedIndex = 1;
        } else if (location.startsWith('/dashboard/profile')) {
          selectedIndex = 2;
        }

        return DashboardShell(selectedIndex: selectedIndex, child: child);
      },
    ),
  ];
}
