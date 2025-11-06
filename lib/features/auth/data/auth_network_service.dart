import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sibi_quest/cores/models/user.dart' as core;
import 'package:sibi_quest/cores/models/user_level_data.dart';

class AuthNetworkService {
  AuthNetworkService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _userCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> _userLevelCollection(
    String userId,
  ) {
    return _userCollection.doc(userId).collection('levelData');
  }

  Future<void> createUserProfile({
    required String userId,
    required core.User user,
  }) async {
    final docRef = _userCollection.doc(userId);
    final data = <String, dynamic>{
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'age': user.age,
      'image': user.image,
      'currentLevel': user.currentLevel,
      'totalScore': user.totalScore,
      'createdAt': FieldValue.serverTimestamp(),
    };

    data.removeWhere((key, value) => value == null);

    await docRef.set(data, SetOptions(merge: true));
  }

  Future<void> createUserLevelDataBatch({
    required String userId,
    required List<({String levelId, UserLevelData data})> levelDataItems,
  }) async {
    if (levelDataItems.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    final collection = _userLevelCollection(userId);

    for (final item in levelDataItems) {
      final docRef = collection.doc(item.levelId);
      final json = item.data.toJson();

      if (item.data.lastAttempted != null) {
        json['lastAttempted'] = Timestamp.fromDate(item.data.lastAttempted!);
      }

      batch.set(docRef, json, SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// Builds the initial level data seed for a new user.
  ///
  /// Optimized to fetch only the first available level instead of all levels.
  /// Uses targeted queries to reduce Firestore reads from ~700 to ~2 per sign-up.
  ///
  /// Returns a single-item list containing the first level marked as available.
  /// All other levels will be created lazily as the user progresses.
  Future<List<({String levelId, UserLevelData data})>>
  buildInitialLevelDataSeed() async {
    try {
      // Fetch ONLY the first section (1 read)
      final sectionsSnapshot = await _firestore
          .collection('sections')
          .orderBy('number')
          .limit(1)
          .get();

      if (sectionsSnapshot.docs.isEmpty) {
        return List.unmodifiable(_defaultLevelDataSeed);
      }

      final firstSectionId = sectionsSnapshot.docs.first.id;

      // Fetch ONLY the first level of that section (1 read)
      final levelsSnapshot = await _firestore
          .collection('levels')
          .where('sectionId', isEqualTo: firstSectionId)
          .orderBy('number')
          .limit(1)
          .get();

      if (levelsSnapshot.docs.isEmpty) {
        return List.unmodifiable(_defaultLevelDataSeed);
      }

      final firstLevelId = levelsSnapshot.docs.first.id;

      // Return only the first level as available
      // Other levels will be created when unlocked during gameplay
      return List.unmodifiable([
        (
          levelId: firstLevelId,
          data: UserLevelData(status: UserLevelStatus.available, bestScore: 0),
        ),
      ]);
    } on FirebaseException catch (error) {
      // Log error for debugging but don't throw
      // Fallback to default seed ensures sign-up always succeeds
      debugPrint('Failed to fetch initial level seed: ${error.message}');
      return List.unmodifiable(_defaultLevelDataSeed);
    } catch (error) {
      debugPrint('Unexpected error in buildInitialLevelDataSeed: $error');
      return List.unmodifiable(_defaultLevelDataSeed);
    }
  }

  static const List<({String levelId, UserLevelData data})>
  _defaultLevelDataSeed = [
    (
      levelId: 'level_1',
      data: UserLevelData(status: UserLevelStatus.available, bestScore: 0),
    ),
    (
      levelId: 'level_2',
      data: UserLevelData(status: UserLevelStatus.locked, bestScore: 0),
    ),
    (
      levelId: 'level_3',
      data: UserLevelData(status: UserLevelStatus.locked, bestScore: 0),
    ),
  ];
}
