import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:sibi_quest/cores/utils/services/cloudinary_service.dart';

/// Firestore + Cloudinary backed profile gateway mirroring the Swift
/// implementation.
class ProfileNetworkService {
  ProfileNetworkService({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? firebaseAuth,
    CloudinaryService? cloudinaryService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _cloudinaryService = cloudinaryService ?? CloudinaryService();

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final CloudinaryService _cloudinaryService;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Persists the provided profile information under `users/{userId}`.
  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    final sanitizedUpdates = Map<String, dynamic>.from(updates)
      ..removeWhere((key, value) => value == null);

    if (sanitizedUpdates.isEmpty) {
      return;
    }

    await _usersCollection
        .doc(userId)
        .set(sanitizedUpdates, SetOptions(merge: true));
  }

  /// Updates the password for the current Firebase user.
  Future<void> updatePassword({required String newPassword}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const ProfileNetworkException.notAuthenticated();
    }

    await user.updatePassword(newPassword);
  }

  /// Uploads a profile image to Cloudinary and updates the Firestore document.
  Future<String> uploadProfileImage({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    final secureUrl = await _cloudinaryService.uploadProfileImage(
      bytes: imageBytes,
      userId: userId,
    );

    await _usersCollection.doc(userId).set({
      'image': secureUrl,
    }, SetOptions(merge: true));

    return secureUrl;
  }

  /// Permanently removes the Firebase Auth account and, once successful,
  /// purges the profile document plus `levelData` subcollection.
  Future<void> deleteAccount({required String userId}) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null || currentUser.uid != userId) {
      throw const ProfileNetworkException.notAuthenticated();
    }

    // Delete Firestore data FIRST while user is still authenticated
    final userDoc = _usersCollection.doc(userId);
    final levelDataSnapshot = await userDoc.collection('levelData').get();
    final batch = _firestore.batch();

    for (final doc in levelDataSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(userDoc);
    await batch.commit();

    // Delete Firebase Auth user LAST
    try {
      await currentUser.delete();
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw ProfileNetworkException.accountDeletionFailed(error.message);
    }
  }

  /// Releases any resources held by the underlying services.
  void dispose() {
    _cloudinaryService.dispose();
  }
}

/// Errors thrown by [ProfileNetworkService].
class ProfileNetworkException implements Exception {
  const ProfileNetworkException._(this.message);

  const ProfileNetworkException.notAuthenticated()
    : this._('User is not authenticated.');

  const ProfileNetworkException.accountDeletionFailed([String? reason])
    : this._('Failed to delete account${reason != null ? ': $reason' : ''}.');

  final String message;

  @override
  String toString() => 'ProfileNetworkException: $message';
}
