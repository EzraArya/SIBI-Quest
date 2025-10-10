sealed class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;
}

class AuthFailureInvalidCredentials extends AuthFailure {
  const AuthFailureInvalidCredentials()
    : super('The email or password you entered is incorrect.');
}

class AuthFailureEmailAlreadyInUse extends AuthFailure {
  const AuthFailureEmailAlreadyInUse()
    : super('An account already exists with this email address.');
}

class AuthFailureWeakPassword extends AuthFailure {
  const AuthFailureWeakPassword()
    : super('Your password is too weak. Please choose a stronger password.');
}

class AuthFailureNetwork extends AuthFailure {
  const AuthFailureNetwork()
    : super('A network error occurred. Check your connection and try again.');
}

class AuthFailureUnknown extends AuthFailure {
  const AuthFailureUnknown([String? detail])
    : super(detail ?? 'An unknown authentication error occurred.');
}
