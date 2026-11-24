import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/manage_auth/auth_bloc.dart';
import '../../../logic/monitor_garagem/monitor_garagem_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/info_chip.dart';
import '../../widgets/painel.dart';
import '../../widgets/trackmod_app_bar.dart';

/// Perfil do piloto: dados da conta, equipe do projeto e estatísticas.
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  static const _integrantes = <(String, String)>[
    ('Augusto Toledo Caires de Oliveira', '199793'),
    ('Italo Carvalhaes Camargo Venerando', '281426'),
    ('Davi Paiva Souza', '222481'),
  ];

  Future<void> _sair(BuildContext context) async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text('Sair da conta?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sair')),
        ],
      ),
    );
    if (sair == true && context.mounted) {
      // Encerra a escuta do Firestore antes de deslogar
      context.read<MonitorGaragemBloc>().add(PararMonitor());
      context.read<AuthBloc>().add(Logout());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final email = auth is Authenticated ? auth.email : '';

    return Scaffold(
      appBar: const TrackModAppBar(titulo: 'Perfil do Piloto'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- CARTÃO DO PILOTO ----------
          Painel(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const AvatarUsuario(tamanho: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Equipe TrackMod',
                          style: AppText.headline(size: 18)),
                      const SizedBox(height: 4),
                      Text(email,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.label(
                              size: 12, color: AppColors.secondary)),
                      const SizedBox(height: 8),
                      const InfoChip('PRO PILOT COCKPIT',
                          cor: AppColors.primary,
                          fundo: AppColors.racingRed20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---------- EQUIPE DO PROJETO ----------
          Painel(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SI700A - FT UNICAMP',
                        style: AppText.label(
                            size: 13, color: AppColors.racingRed)),
                    Text('2026/2', style: AppText.label(size: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Integrantes do Projeto:',
                    style: AppText.body(size: 14)
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                for (final (nome, ra) in _integrantes)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(nome, style: AppText.body(size: 13)),
                        ),
                        Text('RA: $ra',
                            style: AppText.label(
                                size: 12, color: AppColors.secondary)),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text('Orientador: Prof. Ulisses Martins Dias',
                    style: AppText.body(
                        size: 13, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---------- ESTATÍSTICAS ----------
          BlocBuilder<MonitorGaragemBloc, MonitorGaragemState>(
            builder: (context, state) {
              final total = state.pecas.length;
              final instaladas = state.pecas.where((p) => p.instalada).length;
              return Row(
                children: [
                  Expanded(
                      child: _Estatistica(
                          rotulo: 'PEÇAS TOTAIS',
                          valor: '$total',
                          cor: AppColors.onSurface)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _Estatistica(
                          rotulo: 'PEÇAS INSTALADAS',
                          valor: '$instaladas',
                          cor: const Color(0xFF2ECC71))),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // ---------- SAIR ----------
          OutlinedButton.icon(
            onPressed: () => _sair(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.racingRed,
              side: const BorderSide(color: AppColors.racingRed20, width: 1.5),
            ),
            icon: const Icon(Icons.logout, size: 18),
            label: Text('TROCAR DE CONTA / SAIR',
                style: AppText.label(size: 13, color: AppColors.racingRed)),
          ),
        ],
      ),
    );
  }
}

class _Estatistica extends StatelessWidget {
  final String rotulo;
  final String valor;
  final Color cor;
  const _Estatistica(
      {required this.rotulo, required this.valor, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Painel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: AppText.label(size: 11)),
          const SizedBox(height: 8),
          Text(valor, style: AppText.headline(size: 28, color: cor)),
        ],
      ),
    );
  }
}
