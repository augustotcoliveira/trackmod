import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/provider/usuario_provider.dart';
import '../../data/provider/garagem_provider.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late final StreamSubscription<User?> _sub;

  AuthBloc() : super(Unauthenticated()) {
    // Escuta o Firebase: toda mudança de login vira um evento interno
    _sub = UsuarioProvider.helper.usuario.listen((user) {
      add(AuthServerEvent(user?.uid, user?.email));
    });

    on<AuthServerEvent>((event, emit) {
      if (event.uid == null) {
        GaragemProvider.helper.uid = null;
        emit(Unauthenticated());
      } else {
        GaragemProvider.helper.uid = event.uid;
        emit(Authenticated(event.uid!, event.email ?? ''));
      }
    });

    on<LoginUser>((event, emit) async {
      try {
        await UsuarioProvider.helper.entrar(event.email, event.senha);
      } on FirebaseAuthException catch (e) {
        emit(AuthError(e.message ?? 'Falha ao entrar.'));
      }
    });

    on<RegisterUser>((event, emit) async {
      try {
        await UsuarioProvider.helper.cadastrar(event.email, event.senha);
      } on FirebaseAuthException catch (e) {
        emit(AuthError(e.message ?? 'Falha ao cadastrar.'));
      }
    });

    on<Logout>((event, emit) async {
      await UsuarioProvider.helper.sair();
    });
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
