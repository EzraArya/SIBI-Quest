import 'package:cloud_firestore/cloud_firestore.dart';
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

  static List<({String levelId, UserLevelData data})>
  buildInitialLevelDataSeed() {
    return List<({String levelId, UserLevelData data})>.unmodifiable(
      _defaultLevelDataSeed,
    );
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
