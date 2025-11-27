import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/auth/auth_router.dart';
import 'package:sibi_quest/features/dashboard/dashboard_router.dart';
import 'package:sibi_quest/features/onboarding/onboarding_router.dart';
import 'package:sibi_quest/features/play/play_router.dart';
import 'package:sibi_quest/features/profile/profile_router.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final GoRouterRefreshStream _authRefreshStream = GoRouterRefreshStream(
  _firebaseAuth.authStateChanges(),
);

// Central app router. Add feature routes here or via sub-routers in the future.
final appRouter = GoRouter(
  initialLocation: OnboardingRoutes.welcomePath,
  refreshListenable: _authRefreshStream,
  redirect: (context, state) {
    final location = state.uri.path;
    final bool isAuthenticated = _firebaseAuth.currentUser != null;
    final bool isOnboardingRoute = _onboardingRoutes.contains(location);

    if (!isAuthenticated && _requiresAuth(location)) {
      return AuthRoutes.loginPath;
    }

    // Auto-redirect authenticated users from onboarding or login routes
    // But NOT from signup or auth loading - those control their own navigation
    if (isAuthenticated) {
      // Allow signup page to control its own navigation
      if (location == AuthRoutes.signupPath) {
        return null;
      }
      
      // Allow auth loading page for authenticated users
      if (location == AuthRoutes.authLoadingPath) {
        return null;
      }
      
      // Redirect from login and onboarding routes
      if (location == AuthRoutes.loginPath || isOnboardingRoute) {
        return DashboardRoutes.homePath;
      }
    }

    return null;
  },
  routes: [
    ...OnboardingRoutes.routes(),
    ...AuthRoutes.routes(),
    ...DashboardRoutes.routes(),
    ...PlayRoutes.routes(),
    ...ProfileRoutes.routes(),
  ],
);


const Set<String> _onboardingRoutes = {
  OnboardingRoutes.welcomePath,
  OnboardingRoutes.onboardingPath,
};

bool _requiresAuth(String location) {
  if (location.isEmpty) {
    return false;
  }

  for (final prefix in _protectedPrefixes) {
    if (location.startsWith(prefix)) {
      return true;
    }
  }
  return false;
}

const List<String> _protectedPrefixes = [
  DashboardRoutes.dashboardPath,
  DashboardRoutes.homePath,
  DashboardRoutes.leaderboardPath,
  DashboardRoutes.profilePath,
  PlayRoutes.loadingPath,
  PlayRoutes.playPath,
  PlayRoutes.cameraPath,
  PlayRoutes.scorePath,
];

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
