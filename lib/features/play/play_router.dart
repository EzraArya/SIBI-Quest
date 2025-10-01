import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/play/presentation/pages/loading_page.dart';
import 'package:sibi_quest/features/play/presentation/pages/play_page.dart';
import 'package:sibi_quest/features/play/presentation/pages/score_page.dart';
import 'package:sibi_quest/features/play/presentation/pages/camera/camera_page.dart';

class PlayRoutes {
  static const String loadingName = 'loading';
  static const String loadingPath = '/loading';
  static const String scoreName = 'score';
  static const String scorePath = '/score';
  static const String playName = 'play';
  static const String playPath = '/play';
  static const String cameraName = 'camera';
  static const String cameraPath = '/camera';

  static List<GoRoute> routes() => [
    GoRoute(
      name: loadingName,
      path: loadingPath,
      builder: (context, state) {
        final levelId = state.uri.queryParameters['levelId'];
        return LoadingPage(levelId: levelId);
      },
    ),
    GoRoute(
      name: playName,
      path: playPath,
      builder: (context, state) {
        final levelId = state.uri.queryParameters['levelId'];
        return PlayPage(levelId: levelId);
      },
    ),
    GoRoute(
      name: cameraName,
      path: cameraPath,
      builder: (context, state) {
        return const CameraPage();
      },
    ),
    GoRoute(
      name: scoreName,
      path: scorePath,
      builder: (context, state) {
        // Extract score and levelId from query parameters
        final score =
            int.tryParse(state.uri.queryParameters['score'] ?? '0') ?? 0;
        final levelId = state.uri.queryParameters['levelId'];
        return ScorePage(score: score, levelId: levelId);
      },
    ),
  ];
}
