import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sibi_quest/cores/models/level.dart';
import 'package:sibi_quest/cores/models/section.dart';
import 'package:sibi_quest/cores/models/user_level_data.dart';

/// Lightweight Firestore gateway mirroring the Swift `SQHomeNetworkService`.
///
/// The surrounding domain layer can compose these helpers with Riverpod
/// repositories or use them directly for quick prototyping.
class HomeNetworkService {
  HomeNetworkService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Shortcut for the `users/{userId}/levelData` collection.
  CollectionReference<Map<String, dynamic>> _userLevelCollection(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).collection('levelData');
  }

  /// Fetches all available sections from Firestore.
  Future<List<Section>> fetchSections() async {
    final snapshot = await _firestore.collection('sections').get();

    return snapshot.docs.map((doc) {
      final data = <String, dynamic>{'id': doc.id, ...doc.data()};
      return Section.fromJson(data);
    }).toList();
  }

  /// Fetches all levels from Firestore.
  Future<List<Level>> fetchLevels() async {
    final snapshot = await _firestore.collection('levels').get();

    return snapshot.docs.map((doc) {
      final data = <String, dynamic>{'id': doc.id, ...doc.data()};
      return Level.fromJson(data);
    }).toList();
  }

  /// Fetches all level progress documents for a given user.
  ///
  /// Each Firestore document ID is promoted to the `id` field on
  /// [UserLevelData] so callers can correlate data back to specific levels.
  Future<List<UserLevelData>> fetchUserLevelData(String userId) async {
    final snapshot = await _userLevelCollection(userId).get();

    return snapshot.docs.map((doc) {
      final data = <String, dynamic>{'id': doc.id, ...doc.data()};
      return UserLevelData.fromJson(data);
    }).toList();
  }
}
