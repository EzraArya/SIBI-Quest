import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sibi_quest/cores/models/user.dart' as core;
import 'package:sibi_quest/features/auth/data/auth_network_service.dart';
import 'package:sibi_quest/features/auth/data/firebase_auth_repository.dart';
import 'package:sibi_quest/features/auth/domain/auth_repository.dart';

final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) {
  return fb.FirebaseAuth.instance;
});

final authFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authNetworkServiceProvider = Provider<AuthNetworkService>((ref) {
  final firestore = ref.watch(authFirestoreProvider);
  return AuthNetworkService(firestore: firestore);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final authNetworkService = ref.watch(authNetworkServiceProvider);
  return FirebaseAuthRepository(
    firebaseAuth,
    authNetworkService: authNetworkService,
  );
});

final authStateProvider = StreamProvider<core.User?>((ref) {
  return ref.watch(authRepositoryProvider).watchUser();
});

final currentUserProvider = Provider<core.User?>((ref) {
  final asyncUser = ref.watch(authStateProvider);
  return asyncUser.maybeWhen(
    data: (user) => user,
    orElse: () => ref.watch(authRepositoryProvider).currentUser,
  );
});

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  AuthRepository get _repository => ref.watch(authRepositoryProvider);

  @override
  FutureOr<void> build() {}

  Future<void> signIn({required String email, required String password}) {
    return _run(() => _repository.signIn(email: email, password: password));
  }

  Future<void> signUp({required core.User user, required String password}) {
    return _run(() => _repository.signUp(user: user, password: password));
  }

  Future<void> signOut() {
    return _run(_repository.signOut);
  }

  Future<void> sendPasswordReset({required String email}) {
    return _run(() => _repository.sendPasswordReset(email: email));
  }

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
  }
}
