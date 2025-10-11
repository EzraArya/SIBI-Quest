import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:sibi_quest/cores/models/user.dart' as core;
import 'package:sibi_quest/features/auth/domain/auth_failure.dart';
import 'package:sibi_quest/features/auth/domain/auth_repository.dart';
import 'package:sibi_quest/features/home/data/home_network_service.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(
    this._firebaseAuth, {
    required HomeNetworkService homeNetworkService,
  }) : _homeNetworkService = homeNetworkService;

  final fb.FirebaseAuth _firebaseAuth;
  final HomeNetworkService _homeNetworkService;

  @override
  Stream<core.User?> watchUser() {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  core.User? get currentUser => _mapFirebaseUser(_firebaseAuth.currentUser);

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (error) {
      throw _mapFirebaseException(error);
    } catch (_) {
      throw const AuthFailureUnknown();
    }
  }

  @override
  Future<void> signUp({
    required core.User user,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        final displayName = '${user.firstName} ${user.lastName}'.trim();
        if (displayName.isNotEmpty) {
          await firebaseUser.updateDisplayName(displayName);
        }
        if (user.image != null && user.image!.isNotEmpty) {
          await firebaseUser.updatePhotoURL(user.image);
        }

        // Seed default level progress so the Home dashboard has data on first load.
        await _homeNetworkService.createUserLevelDataBatch(
          userId: firebaseUser.uid,
          levelDataItems: HomeNetworkService.buildInitialLevelDataSeed(),
        );
      }
    } on fb.FirebaseAuthException catch (error) {
      throw _mapFirebaseException(error);
    } catch (_) {
      throw const AuthFailureUnknown();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on fb.FirebaseAuthException catch (error) {
      throw _mapFirebaseException(error);
    } catch (_) {
      throw const AuthFailureUnknown();
    }
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (error) {
      throw _mapFirebaseException(error);
    } catch (_) {
      throw const AuthFailureUnknown();
    }
  }

  core.User? _mapFirebaseUser(fb.User? user) {
    if (user == null) {
      return null;
    }

    final displayName = (user.displayName ?? '').trim();
    String firstName = '';
    String lastName = '';
    if (displayName.isNotEmpty) {
      final parts = displayName.split(RegExp(r'\s+'));
      firstName = parts.first;
      if (parts.length > 1) {
        lastName = parts.sublist(1).join(' ');
      }
    }

    return core.User(
      id: user.uid,
      firstName: firstName,
      lastName: lastName,
      email: user.email ?? '',
      age: 0,
      createdAt: user.metadata.creationTime,
      image: user.photoURL,
      currentLevel: null,
      totalScore: 0,
    );
  }

  AuthFailure _mapFirebaseException(fb.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'user-disabled':
        return const AuthFailureInvalidCredentials();
      case 'email-already-in-use':
        return const AuthFailureEmailAlreadyInUse();
      case 'weak-password':
        return const AuthFailureWeakPassword();
      case 'network-request-failed':
        return const AuthFailureNetwork();
      default:
        return AuthFailureUnknown(error.message);
    }
  }
}
