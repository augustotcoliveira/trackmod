import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/manage_auth/auth_bloc.dart';
import '../../logic/monitor_garagem/monitor_garagem_bloc.dart';
import '../theme/app_theme.dart';

/// Cabeçalho padrão das abas: logo + título + avatar com menu de opções da conta.
class TrackModAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  const TrackModAppBar({super.key, required this.titulo});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  Future<void> _sair(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text('Sair da conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmou == true && context.mounted) {
      context.read<MonitorGaragemBloc>().add(PararMonitor());
      context.read<AuthBloc>().add(Logout());
    }
  }

  void _mostrarDetalhes(BuildContext context, String email, String uid) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DETALHES DA CONTA', style: AppText.label()),
              const SizedBox(height: 16),
              Row(
                children: [
                  const AvatarUsuario(tamanho: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Piloto Registrado',
                            style: AppText.headline(size: 16)),
                        const SizedBox(height: 2),
                        Text(email,
                            style: AppText.body(
                                size: 13, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.surfaceContainerHighest),
              const SizedBox(height: 12),
              Text('ID do Usuário (UID Firebase):',
                  style: AppText.label(size: 11)),
              const SizedBox(height: 4),
              SelectableText(
                uid.isEmpty ? '(não autenticado)' : uid,
                style: AppText.body(size: 12, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Text('Projeto: TrackMod Cockpit (SI700A)',
                  style: AppText.label(size: 11)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          const _Logo(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: AppText.headline(size: 22),
            ),
          ),
        ],
      ),
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final logado = state is Authenticated;
            final email = logado ? state.email : '';
            final uid = logado ? state.uid : '';

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 48),
                color: AppColors.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tooltip: 'Opções da conta',
                child: const AvatarUsuario(tamanho: 36),
                onSelected: (opcao) {
                  if (opcao == 'detalhes') {
                    _mostrarDetalhes(context, email, uid);
                  } else if (opcao == 'sair') {
                    _sair(context);
                  }
                },
                itemBuilder: (ctx) => [
                  if (logado) ...[
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CONTA', style: AppText.label(size: 10)),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body(size: 13, color: AppColors.primary)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Divider(height: 16),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'detalhes',
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline, size: 20),
                          const SizedBox(width: 12),
                          Text('Detalhes da conta', style: AppText.body(size: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'sair',
                      child: Row(
                        children: [
                          const Icon(Icons.logout,
                              size: 20, color: AppColors.racingRed),
                          const SizedBox(width: 12),
                          Text(
                            'Sair da conta',
                            style: AppText.body(
                                size: 14, color: AppColors.racingRed),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Text('Visitante (não logado)',
                          style: AppText.label(size: 12)),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.racingRed20),
      ),
      // Arquivo em assets/images/logo.png (se faltar, mostra o ícone)
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, erro, stack) =>
            const Icon(Icons.speed, color: AppColors.primary),
      ),
    );
  }
}

/// Círculo com a inicial do e-mail do usuário logado (ou um ícone de pessoa).
class AvatarUsuario extends StatelessWidget {
  final double tamanho;
  const AvatarUsuario({super.key, this.tamanho = 36});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final email = state is Authenticated ? state.email : '';
        return Container(
          width: tamanho,
          height: tamanho,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceContainerHigh,
            border: Border.all(color: AppColors.racingRed, width: 2),
          ),
          child: email.isEmpty
              ? Icon(Icons.person, size: tamanho * 0.55, color: AppColors.primary)
              : Text(
                  email[0].toUpperCase(),
                  style: AppText.headline(
                      size: tamanho * 0.45, color: AppColors.primary),
                ),
        );
      },
    );
  }
}
