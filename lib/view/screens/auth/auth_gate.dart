import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/manage_auth/auth_bloc.dart';
import 'login_screen.dart';

/// Mostra o [child] só para usuário logado; caso contrário, a tela de login.
/// Mesmo papel do "Wrapper" visto em aula, mas aplicado por aba,
/// porque a Vitrine precisa continuar pública.
class AuthGate extends StatelessWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) return child;
        return const LoginScreen();
      },
    );
  }
}
