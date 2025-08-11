import 'package:flutter/material.dart';
import 'package:sibi_quest/app/theme.dart';

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
    return MaterialApp(
      title: title,
      navigatorKey: navigatorKey,
      theme: theme ?? buildDarkTheme(),
      home: home,
      // If you later add routing, replace `home` with `onGenerateRoute`/`routerConfig`.
      debugShowCheckedModeBanner: false,
    );
  }
}
