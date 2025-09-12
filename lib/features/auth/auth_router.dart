import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/auth/presentation/pages/login_page.dart';
import 'package:sibi_quest/features/auth/presentation/pages/signup_page.dart';

class AuthRoutes {
  static const String loginName = 'login';
  static const String loginPath = '/login';
  static const String signupName = 'signup';
  static const String signupPath = '/signup';

  static List<GoRoute> routes() => [
    GoRoute(
      name: loginName,
      path: loginPath,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      name: signupName,
      path: signupPath,
      builder: (context, state) => const SignupPage(),
    ),
  ];
}
