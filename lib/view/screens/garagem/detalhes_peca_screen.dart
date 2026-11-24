import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/models/peca.dart';
import '../../../logic/manage_garagem/manage_garagem_bloc.dart';
import '../../../logic/monitor_garagem/monitor_garagem_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/confirmar_exclusao.dart';
import '../../widgets/info_chip.dart';
import '../../widgets/painel.dart';
import 'add_peca_screen.dart';

final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
final _data = DateFormat('dd/MM/yyyy');

/// Detalhes de uma peça, com opções de editar, marcar como instalada e remover.
/// Recebe só o id e busca a peça no MonitorGaragemBloc, assim a tela
/// se atualiza sozinha depois de uma edição.
class DetalhesPecaScreen extends StatelessWidget {
  final String pecaId;
  const DetalhesPecaScreen({super.key, required this.pecaId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonitorGaragemBloc, MonitorGaragemState>(
      builder: (context, state) {
        final achadas = state.pecas.where((p) => p.id == pecaId).toList();
        if (achadas.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('DETALHES DA PEÇA')),
            body: Center(
                child: Text('Peça não encontrada.', style: AppText.label())),
          );
        }
        return _Conteudo(peca: achadas.first);
      },
    );
  }
}

class _Conteudo extends StatelessWidget {
  final Peca peca;
  const _Conteudo({required this.peca});

  @override
  Widget build(BuildContext context) {
    final linhas = <(String, String)>[
      ('VALOR PAGO', _moeda.format(peca.valor)),
      if (peca.consumivel) ('QUANTIDADE', 'x${peca.quantidade}'),
      ('DATA DA COMPRA', _data.format(peca.dataCompra)),
      ('GANHO ESTIMADO', '+${peca.ganhoHp.round()} HP'),
      ('ESTADO', peca.estadoTexto),
      ('NOTA FISCAL / GARANTIA', peca.comNotaFiscal ? 'Sim' : 'Não'),
      ('TIPO', peca.consumivel ? 'Estoque consumível' : 'Peça instalável'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('DETALHES DA PEÇA')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- FOTO ----------
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: peca.foto != null
                  ? Image.memory(peca.foto!,
                      fit: BoxFit.cover, gaplessPlayback: true)
                  : Container(
                      color: AppColors.surfaceContainerHighest,
                      child: const Icon(Icons.build_outlined,
                          size: 56, color: AppColors.onSurfaceVariant),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // ---------- NOME, CHIPS E TOTAL ----------
          Text(peca.nome.trim().isEmpty ? '(sem nome)' : peca.nome,
              style: AppText.headline(size: 26)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              InfoChip(peca.categoria.toUpperCase()),
              InfoChip(peca.estadoTexto.toUpperCase()),
              if (peca.instalada)
                const InfoChip('INSTALADA',
                    cor: Color(0xFF2ECC71), fundo: Color(0x332ECC71)),
            ],
          ),
          const SizedBox(height: 20),
          Text('TOTAL INVESTIDO NESTA PEÇA', style: AppText.label(size: 12)),
          const SizedBox(height: 4),
          Text(_moeda.format(peca.valorTotal),
              style: AppText.headline(size: 32, color: AppColors.primary)),
          const SizedBox(height: 20),

          // ---------- FICHA TÉCNICA ----------
          Painel(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (var i = 0; i < linhas.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: AppColors.surfaceContainerHighest),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(linhas[i].$1, style: AppText.label(size: 12)),
                        Flexible(
                          child: Text(linhas[i].$2,
                              textAlign: TextAlign.right,
                              style: AppText.body(size: 15)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---------- SWITCH: INSTALADA ----------
          Painel(
            child: SwitchListTile(
              secondary: const Icon(Icons.build_circle_outlined),
              title: const Text('Instalada no carro'),
              subtitle: Text(
                peca.instalada
                    ? 'Rodando no projeto'
                    : 'Guardada, aguardando instalação',
                style: AppText.label(size: 11),
              ),
              value: peca.instalada,
              onChanged: (v) {
                final alterada = peca.clone()..instalada = v;
                context.read<ManageGaragemBloc>().add(UpdatePeca(alterada));
              },
            ),
          ),
          const SizedBox(height: 24),

          // ---------- AÇÕES ----------
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddPecaScreen(pecaExistente: peca)),
            ),
            icon: const Icon(Icons.edit),
            label: const Text('Editar peça'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final removida = await confirmarExclusao(context, peca);
              if (removida && context.mounted) Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remover peça'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
