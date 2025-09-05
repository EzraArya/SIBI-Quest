import 'package:flutter/material.dart';
import 'package:sibi_quest/app/theme.dart';
import 'package:sibi_quest/app/app_router.dart';

/// Root application widget. Keep `main.dart` as a thin entry point
/// and put your app wiring (theme, router, etc.) here.
class App extends StatelessWidget {
  const App({
    super.key,
    this.home,
    this.title = 'Sibi Quest',
    this.theme,
    this.navigatorKey,
  });

  final Widget? home;
  final String title;
  final ThemeData? theme;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context) {
    if (home != null) {
      return MaterialApp(
        title: title,
        navigatorKey: navigatorKey,
        theme: theme ?? buildDarkTheme(),
        home: home,
        debugShowCheckedModeBanner: false,
      );
    }
    return MaterialApp.router(
      title: title,
      theme: theme ?? buildDarkTheme(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
