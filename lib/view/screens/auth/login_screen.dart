import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/manage_auth/auth_bloc.dart';
import '../../theme/app_theme.dart';

/// Tela de autenticação (versão inicial, será refinada depois).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _senha = '';
  bool _ocultarSenha = true;

  void _enviar({required bool cadastro}) {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    context.read<AuthBloc>().add(
        cadastro ? RegisterUser(_email, _senha) : LoginUser(_email, _senha));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.mensagem)));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.speed,
                          size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: 24),
                    Text('TrackMod', style: AppText.headline(size: 32)),
                    Text('Performance Digital Cockpit',
                        style: AppText.body(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 40),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          hintText: 'E-mail',
                          prefixIcon: Icon(Icons.mail_outline)),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Informe um e-mail válido'
                          : null,
                      onSaved: (v) => _email = v!.trim(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      obscureText: _ocultarSenha,
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_ocultarSenha
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _ocultarSenha = !_ocultarSenha),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Mínimo de 6 caracteres'
                          : null,
                      onSaved: (v) => _senha = v!,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _enviar(cadastro: false),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Entrar'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _enviar(cadastro: true),
                      child: const Text('Criar conta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
