import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sibi_quest/cores/models/user.dart' as core;
import 'package:sibi_quest/features/auth/data/firebase_auth_repository.dart';
import 'package:sibi_quest/features/auth/domain/auth_failure.dart';
import 'package:sibi_quest/features/auth/domain/auth_repository.dart';

final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) {
  return fb.FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(firebaseAuth);
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

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthController(repository);
    });

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._repository) : super(const AsyncData(null));

  final AuthRepository _repository;

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
    try {
      await action();
      state = const AsyncData(null);
    } on AuthFailure catch (failure) {
      state = AsyncError(failure, StackTrace.current);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
