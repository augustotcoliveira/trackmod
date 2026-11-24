abstract class AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final String uid;
  final String email;
  Authenticated(this.uid, this.email);
}

class AuthError extends AuthState {
  final String mensagem;
  AuthError(this.mensagem);
}
