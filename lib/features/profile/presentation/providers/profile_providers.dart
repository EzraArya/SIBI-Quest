import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sibi_quest/cores/models/user.dart' as core;
import 'package:sibi_quest/cores/utils/manager/secret_manager.dart';
import 'package:sibi_quest/cores/utils/services/cloudinary_service.dart';
import 'package:sibi_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:sibi_quest/features/profile/data/profile_network_service.dart';

final profileFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final profileFirebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

final secretManagerProvider = Provider<SecretManager>((ref) {
  final manager = SecretManager();
  ref.onDispose(manager.clearCache);
  return manager;
});

final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  final service = CloudinaryService(
    secretManager: ref.watch(secretManagerProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final profileNetworkServiceProvider = Provider<ProfileNetworkService>((ref) {
  final firestore = ref.watch(profileFirestoreProvider);
  final firebaseAuth = ref.watch(profileFirebaseAuthProvider);
  final cloudinary = ref.watch(cloudinaryServiceProvider);
  return ProfileNetworkService(
    firestore: firestore,
    firebaseAuth: firebaseAuth,
    cloudinaryService: cloudinary,
  );
});

final profileUserStreamProvider = StreamProvider<core.User?>((ref) {
  final authUser = ref.watch(currentUserProvider);
  final userId = authUser?.id;

  if (userId == null || userId.isEmpty) {
    return Stream<core.User?>.value(null);
  }

  final firestore = ref.watch(profileFirestoreProvider);
  final docRef = firestore.collection('users').doc(userId);

  return docRef.snapshots().map((snapshot) {
    final data = snapshot.data();
    if (data == null) {
      return null;
    }

    return core.User.fromJson(<String, dynamic>{'id': snapshot.id, ...data});
  });
});

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(ProfileController.new);

class ProfileController extends AsyncNotifier<void> {
  ProfileNetworkService get _service => ref.read(profileNetworkServiceProvider);

  @override
  Future<void> build() async {}

  Future<void> updateProfile({required core.User profile}) async {
    final userId = profile.id ?? ref.read(currentUserProvider)?.id;
    if (userId == null || userId.isEmpty) {
      throw const ProfileNetworkException.notAuthenticated();
    }

    await _execute(() async {
      await _service.updateProfile(userId: userId, profile: profile);
      ref.invalidate(currentUserProvider);
    });
  }

  Future<void> updatePassword({required String newPassword}) async {
    await _execute(() async {
      await _service.updatePassword(newPassword: newPassword);
    });
  }

  Future<String> uploadProfileImage({
    required Uint8List imageBytes,
    required String userId,
  }) async {
    late final String imageUrl;
    await _execute(() async {
      imageUrl = await _service.uploadProfileImage(
        userId: userId,
        imageBytes: imageBytes,
      );
      ref.invalidate(currentUserProvider);
    });
    return imageUrl;
  }

  Future<void> deleteAccount({required String userId}) async {
    await _execute(() async {
      await _service.deleteAccount(userId: userId);
      ref.invalidate(currentUserProvider);
      ref.invalidate(authStateProvider);
    });
  }

  Future<void> _execute(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
