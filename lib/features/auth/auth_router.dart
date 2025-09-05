import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/auth/presentation/pages/login_page.dart';

class AuthRoutes {
  static const String loginName = 'login';
  static const String loginPath = '/login';

  static List<GoRoute> routes() => [
    GoRoute(
      name: loginName,
      path: loginPath,
      builder: (context, state) => const LoginPage(),
    ),
  ];
}
