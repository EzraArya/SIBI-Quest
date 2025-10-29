import 'package:flutter_test/flutter_test.dart';
import 'package:sibi_quest/features/play/domain/services/classifier_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ClassifierService', () {
    final service = ClassifierService();

    tearDown(() async {
      await service.dispose();
    });

    test('returns fallback result when image file is missing', () async {
      final result = await service.predict('does/not/exist.jpg');
      expect(result.isFallback, isTrue);
      expect(result.label, 'Unknown');
      expect(result.confidence, 0);
    });
  });
}
