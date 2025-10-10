import 'package:sibi_quest/cores/models/user.dart' as core;

abstract class AuthRepository {
  Stream<core.User?> watchUser();
  core.User? get currentUser;

  Future<void> signIn({required String email, required String password});
  Future<void> signUp({required core.User user, required String password});
  Future<void> signOut();
  Future<void> sendPasswordReset({required String email});
}
