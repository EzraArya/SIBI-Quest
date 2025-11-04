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

  Future<List<({String levelId, UserLevelData data})>>
  buildInitialLevelDataSeed() async {
    try {
      final sectionsSnapshot = await _firestore.collection('sections').get();
      final levelsSnapshot = await _firestore.collection('levels').get();

      if (levelsSnapshot.docs.isEmpty) {
        return List.unmodifiable(_defaultLevelDataSeed);
      }

      final sortedSections = sectionsSnapshot.docs
          .map(
            (doc) => (
              id: doc.id,
              number: (doc.data()['number'] as num?)?.toInt(),
            ),
          )
          .toList()
        ..sort(
          (a, b) {
            final aNumber = a.number;
            final bNumber = b.number;
            if (aNumber != null && bNumber != null) {
              final compare = aNumber.compareTo(bNumber);
              if (compare != 0) {
                return compare;
              }
            } else if (aNumber != null) {
              return -1;
            } else if (bNumber != null) {
              return 1;
            }
            return a.id.compareTo(b.id);
          },
        );

      final sectionOrder = <String, int>{
        for (var index = 0; index < sortedSections.length; index++)
          sortedSections[index].id: index,
      };
      final firstSectionId =
          sortedSections.isNotEmpty ? sortedSections.first.id : null;

      final docs = levelsSnapshot.docs
          .map(
            (doc) => (
              id: doc.id,
              number: (doc.data()['number'] as num?)?.toInt(),
              sectionId: doc.data()['sectionId'] as String?,
            ),
          )
          .toList()
        ..sort(
          (a, b) {
            final aSectionIndex =
                sectionOrder[a.sectionId] ?? sectionOrder.length;
            final bSectionIndex =
                sectionOrder[b.sectionId] ?? sectionOrder.length;
            final sectionCompare = aSectionIndex.compareTo(bSectionIndex);
            if (sectionCompare != 0) {
              return sectionCompare;
            }

            final aNumber = a.number;
            final bNumber = b.number;
            if (aNumber != null && bNumber != null) {
              final compare = aNumber.compareTo(bNumber);
              if (compare != 0) {
                return compare;
              }
            } else if (aNumber != null) {
              return -1;
            } else if (bNumber != null) {
              return 1;
            }
            return a.id.compareTo(b.id);
          },
        );

      final seeds = <({String levelId, UserLevelData data})>[];
      var availableAssigned = false;

      for (final doc in docs) {
        final isFirstLevelOfFirstSection = firstSectionId != null &&
            doc.sectionId == firstSectionId &&
            (doc.number == 1 || doc.number == null);

        final shouldMarkAvailable =
            !availableAssigned && (isFirstLevelOfFirstSection || firstSectionId == null);

        final status = shouldMarkAvailable
            ? UserLevelStatus.available
            : UserLevelStatus.locked;

        if (shouldMarkAvailable) {
          availableAssigned = true;
        }

        seeds.add((
          levelId: doc.id,
          data: UserLevelData(
            status: status,
            bestScore: 0,
          ),
        ));
      }

      if (seeds.isNotEmpty && !availableAssigned) {
        final first = seeds.first;
        seeds[0] = (
          levelId: first.levelId,
          data: first.data.copyWith(status: UserLevelStatus.available),
        );
      }

      return List.unmodifiable(seeds);
    } on FirebaseException {
      return List.unmodifiable(_defaultLevelDataSeed);
    } catch (_) {
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
