abstract class AuthEvent {}

/// Evento interno disparado pelo stream do Firebase Auth.
class AuthServerEvent extends AuthEvent {
  final String? uid;
  final String? email;
  AuthServerEvent(this.uid, this.email);
}

class LoginUser extends AuthEvent {
  final String email;
  final String senha;
  LoginUser(this.email, this.senha);
}

class RegisterUser extends AuthEvent {
  final String email;
  final String senha;
  RegisterUser(this.email, this.senha);
}

class Logout extends AuthEvent {}
