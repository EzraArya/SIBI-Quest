import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sibi_quest/features/home/domain/models/level.dart'
    as domain_level;
import 'package:sibi_quest/cores/models/user_level_data.dart';
import 'package:sibi_quest/features/play/domain/models/questions.dart';

/// Firestore-backed counterpart to the Swift `SQPlayNetworkService`.
class PlayNetworkService {
  PlayNetworkService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _levelsCollection =>
      _firestore.collection('levels');

  CollectionReference<Map<String, dynamic>> get _questionsCollection =>
      _firestore.collection('questions');

  CollectionReference<Map<String, dynamic>> _userLevelCollection(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).collection('levelData');
  }

  /// Fetches a level document by [levelId].
  Future<domain_level.Level> fetchLevel({required String levelId}) async {
    try {
      final snapshot = await _levelsCollection.doc(levelId).get();
      if (!snapshot.exists) {
        throw PlayNetworkException.levelNotFound(levelId);
      }

      final data = snapshot.data();
      if (data == null) {
        throw PlayNetworkException.levelNotFound(levelId);
      }

      final payload = <String, dynamic>{'id': snapshot.id, ...data};
      return domain_level.Level.fromJson(payload);
    } on FirebaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        PlayNetworkException.firebaseFailure(error.message),
        stackTrace,
      );
    }
  }

  /// Fetches all questions belonging to a specific [levelId].
  Future<List<Question>> fetchQuestions({required String levelId}) async {
    try {
      final snapshot = await _questionsCollection
          .where('levelId', isEqualTo: levelId)
          .get();

      if (snapshot.docs.isEmpty) {
        return const [];
      }

      final docs = snapshot.docs.map((doc) => _QuestionSnapshot(doc)).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      return docs.map((doc) => doc.toQuestion()).toList();
    } on FirebaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        PlayNetworkException.firebaseFailure(error.message),
        stackTrace,
      );
    } on PlayNetworkException {
      rethrow;
    }
  }

  /// Updates the user's aggregated level data under `users/{userId}`.
  Future<void> updateUserLevelData({
    required String userId,
    required String levelId,
    required UserLevelData userLevelData,
  }) async {
    try {
      final docRef = _userLevelCollection(userId).doc(levelId);
      final existing = await docRef.get();

      UserLevelData? current;
      if (existing.exists) {
        final data = existing.data();
        if (data != null) {
          current = UserLevelData.fromJson(<String, dynamic>{
            'id': existing.id,
            ...data,
          });
        }
      }

      final merged = _mergeUserLevelData(current, userLevelData);
      final payload = _encodeUserLevelData(merged);

      await docRef.set(payload, SetOptions(merge: true));
    } on FirebaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        PlayNetworkException.firebaseFailure(error.message),
        stackTrace,
      );
    }
  }

  UserLevelData _mergeUserLevelData(
    UserLevelData? current,
    UserLevelData incoming,
  ) {
    if (current == null) {
      return incoming;
    }

    final bestScore = incoming.bestScore >= current.bestScore
        ? incoming.bestScore
        : current.bestScore;

    final status = switch ((current.status, incoming.status)) {
      (UserLevelStatus.completed, _) => UserLevelStatus.completed,
      (_, UserLevelStatus.completed) => UserLevelStatus.completed,
      (_, UserLevelStatus.available) => UserLevelStatus.available,
      _ => UserLevelStatus.locked,
    };

    final lastAttempted = incoming.lastAttempted ?? current.lastAttempted;

    return incoming.copyWith(
      id: current.id,
      bestScore: bestScore,
      status: status,
      lastAttempted: lastAttempted,
    );
  }

  Map<String, dynamic> _encodeUserLevelData(UserLevelData data) {
    final payload = <String, dynamic>{
      'status': data.status.json,
      'bestScore': data.bestScore,
    };

    if (data.lastAttempted != null) {
      payload['lastAttempted'] = Timestamp.fromDate(data.lastAttempted!);
    }

    return payload;
  }
}

class _QuestionSnapshot {
  _QuestionSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : id = snapshot.id,
      data = snapshot.data();

  final String id;
  final Map<String, dynamic> data;

  int get order => (data['order'] as num?)?.toInt() ?? 0;

  Question toQuestion() {
    final contentRaw = data['content'];
    if (contentRaw is! Map<String, dynamic>) {
      throw PlayNetworkException.invalidQuestionPayload(id);
    }

    final answersRaw = contentRaw['answers'];
    final answers = answersRaw is List
        ? answersRaw.map((entry) {
            if (entry is Map<String, dynamic>) {
              return Map<String, dynamic>.from(entry);
            }
            if (entry is Map) {
              return entry.map((key, value) {
                return MapEntry(key.toString(), value);
              });
            }
            throw PlayNetworkException.invalidQuestionPayload(id);
          }).toList()
        : const <Map<String, dynamic>>[];

    final content = <String, dynamic>{
      'prompt': contentRaw['prompt'] as String? ?? '',
      'isPromptImage': contentRaw['isPromptImage'] as bool? ?? false,
      'answers': answers,
      'exampleImage': contentRaw['exampleImage'],
    };

    final payload = <String, dynamic>{
      'id': id,
      'levelId': data['levelId'] as String? ?? '',
      'type': data['type'] as String? ?? '',
      'content': content,
      'correctAnswerIndex': (data['correctAnswerIndex'] as num?)?.toInt() ?? 0,
    };

    return Question.fromJson(payload);
  }
}

/// Errors thrown by [PlayNetworkService].
class PlayNetworkException implements Exception {
  const PlayNetworkException._(this.message);

  PlayNetworkException.levelNotFound(String levelId)
    : this._('Level "$levelId" was not found.');

  PlayNetworkException.invalidQuestionPayload(String questionId)
    : this._('Invalid question payload for "$questionId".');

  PlayNetworkException.firebaseFailure(String? reason)
    : this._(
        'Failed to communicate with Firestore${reason != null ? ': $reason' : ''}.',
      );

  final String message;

  @override
  String toString() => 'PlayNetworkException: $message';
}
