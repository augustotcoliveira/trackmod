import 'package:firebase_auth/firebase_auth.dart';

/// Camada de acesso ao Firebase Authentication (padrão singleton "helper").
/// Não pode se chamar AuthProvider, nome que já existe dentro do firebase_auth.
class UsuarioProvider {
  static final UsuarioProvider helper = UsuarioProvider._createInstance();
  UsuarioProvider._createInstance();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Emite o usuário logado (ou null) sempre que o estado de login muda.
  Stream<User?> get usuario => _auth.authStateChanges();

  Future<void> entrar(String email, String senha) =>
      _auth.signInWithEmailAndPassword(email: email, password: senha);

  Future<void> cadastrar(String email, String senha) =>
      _auth.createUserWithEmailAndPassword(email: email, password: senha);

  Future<void> sair() => _auth.signOut();

  // TODO: login com Google exige o pacote google_sign_in + SHA1 no console.
}
