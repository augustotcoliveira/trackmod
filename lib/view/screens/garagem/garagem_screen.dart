import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/models/peca.dart';
import '../../../logic/monitor_garagem/monitor_garagem_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/confirmar_exclusao.dart';
import '../../widgets/info_chip.dart';
import '../../widgets/trackmod_app_bar.dart';
import 'add_peca_screen.dart';
import 'detalhes_peca_screen.dart';

final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

/// Minha Garagem: card de Total Investido + ListView com o inventário.
class GaragemScreen extends StatefulWidget {
  const GaragemScreen({super.key});

  @override
  State<GaragemScreen> createState() => _GaragemScreenState();
}

class _GaragemScreenState extends State<GaragemScreen> {
  String? _filtro; // null = todas as categorias

  @override
  void initState() {
    super.initState();
    // Só chega aqui com usuário logado (AuthGate), então o uid já existe
    context.read<MonitorGaragemBloc>().add(IniciarMonitor());
  }

  /// BottomSheet com as categorias para filtrar a lista.
  void _abrirFiltro() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FILTRAR POR CATEGORIA', style: AppText.label()),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final c in <String?>[null, ...Categorias.todas])
                    ChoiceChip(
                      label: Text(c ?? 'Todas'),
                      selected: _filtro == c,
                      onSelected: (_) {
                        setState(() => _filtro = c);
                        Navigator.pop(ctx);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrackModAppBar(titulo: 'Minha Garagem'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.racingRed,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPecaScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nova peça'),
      ),
      body: BlocBuilder<MonitorGaragemBloc, MonitorGaragemState>(
        builder: (context, state) {
          final todas = state.pecas;
          final lista = _filtro == null
              ? todas
              : todas.where((p) => p.categoria == _filtro).toList();
          final linhas = lista.isEmpty ? 1 : lista.length;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: linhas + 2,
            itemBuilder: (context, i) {
              if (i == 0) return _CardTotal(pecas: todas);
              if (i == 1) {
                return _CabecalhoInventario(
                  quantidade: lista.length,
                  filtro: _filtro,
                  onFiltrar: _abrirFiltro,
                );
              }
              if (lista.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text('Nenhuma peça por aqui ainda.',
                        style: AppText.label()),
                  ),
                );
              }
              return _ItemInventario(peca: lista[i - 2]);
            },
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------------
// CARD "TOTAL INVESTIDO"
// ------------------------------------------------------------------
class _CardTotal extends StatelessWidget {
  final List<Peca> pecas;
  const _CardTotal({required this.pecas});

  @override
  Widget build(BuildContext context) {
    final total = pecas.fold<double>(0, (soma, p) => soma + p.valorTotal);

    // Quanto do total foi investido nos últimos 30 dias
    final limite = DateTime.now().subtract(const Duration(days: 30));
    final recente = pecas
        .where((p) => p.dataCompra.isAfter(limite))
        .fold<double>(0, (soma, p) => soma + p.valorTotal);
    final antes = total - recente;
    String? variacao;
    if (pecas.isNotEmpty) {
      if (antes > 0) {
        variacao = '+${(recente / antes * 100).round()}%';
      } else if (recente > 0) {
        variacao = 'NOVO';
      }
    }

    // Pontos do gráfico: investimento acumulado ao longo do tempo
    final ordenadas = [...pecas]
      ..sort((a, b) => a.dataCompra.compareTo(b.dataCompra));
    final pontos = <double>[0];
    var acumulado = 0.0;
    for (final p in ordenadas) {
      acumulado += p.valorTotal;
      pontos.add(acumulado);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B1F1F), AppColors.surfaceContainer],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 20, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text('TOTAL INVESTIDO', style: AppText.label()),
              const Spacer(),
              if (variacao != null)
                InfoChip(variacao,
                    cor: AppColors.secondary,
                    fundo: AppColors.secondary20,
                    icone: Icons.trending_up),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(_moeda.format(total),
                style: AppText.headline(size: 40, color: AppColors.primary)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            width: double.infinity,
            child: CustomPaint(painter: _SparklinePainter(pontos)),
          ),
        ],
      ),
    );
  }
}

/// Gráfico de linha suave (sparkline) do investimento acumulado.
class _SparklinePainter extends CustomPainter {
  final List<double> pontos;
  _SparklinePainter(this.pontos);

  @override
  void paint(Canvas canvas, Size size) {
    if (pontos.length < 2) return;

    var minV = pontos.first;
    var maxV = pontos.first;
    for (final v in pontos) {
      if (v < minV) minV = v;
      if (v > maxV) maxV = v;
    }
    final faixa = (maxV - minV) == 0 ? 1.0 : (maxV - minV);
    final dx = size.width / (pontos.length - 1);

    Offset ponto(int i) => Offset(
          i * dx,
          size.height - 4 - ((pontos[i] - minV) / faixa) * (size.height - 8),
        );

    final linha = Path()..moveTo(ponto(0).dx, ponto(0).dy);
    for (var i = 1; i < pontos.length; i++) {
      final a = ponto(i - 1);
      final b = ponto(i);
      final cx = (a.dx + b.dx) / 2;
      linha.cubicTo(cx, a.dy, cx, b.dy, b.dx, b.dy);
    }

    final area = Path.from(linha)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      area,
      Paint()
        ..color = const Color(0x1AFFB3B1)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      linha,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}

// ------------------------------------------------------------------
// CABEÇALHO DA LISTA
// ------------------------------------------------------------------
class _CabecalhoInventario extends StatelessWidget {
  final int quantidade;
  final String? filtro;
  final VoidCallback onFiltrar;
  const _CabecalhoInventario({
    required this.quantidade,
    required this.filtro,
    required this.onFiltrar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Text('Inventário', style: AppText.headline(size: 24)),
          const SizedBox(width: 10),
          InfoChip(quantidade == 1 ? '1 item' : '$quantidade itens'),
          const Spacer(),
          TextButton.icon(
            onPressed: onFiltrar,
            style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
            icon: const Icon(Icons.filter_list, size: 18),
            label: Text((filtro ?? 'Filtrar').toUpperCase(),
                style: AppText.label(size: 12, color: AppColors.secondary)),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// ITEM DO INVENTÁRIO
// ------------------------------------------------------------------
class _ItemInventario extends StatelessWidget {
  final Peca peca;
  const _ItemInventario({required this.peca});

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(12);
    final nome = peca.nome.trim().isEmpty ? '(sem nome)' : peca.nome;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surfaceContainer,
        borderRadius: raio,
        child: InkWell(
          borderRadius: raio,
          // Toque no cartão abre os detalhes (de lá dá para editar e excluir)
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DetalhesPecaScreen(pecaId: peca.id!)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _Foto(peca: peca),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(size: 16, color: AppColors.onSurface)
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          InfoChip(peca.categoria.toUpperCase()),
                          Text('• ${peca.estadoTexto}',
                              style: AppText.label(size: 11)),
                          if (peca.consumivel)
                            Text('x${peca.quantidade}',
                                style: AppText.label(size: 11)),
                          if (peca.ganhoHp > 0)
                            Text('+${peca.ganhoHp.round()}hp',
                                style: AppText.label(
                                    size: 11, color: AppColors.secondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_moeda.format(peca.valorTotal),
                        style: AppText.label(
                                size: 15, color: AppColors.primary)
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => confirmarExclusao(context, peca),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.delete_outline,
                            size: 20, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Foto da peça (ou ícone) com uma bolinha verde quando está instalada.
class _Foto extends StatelessWidget {
  final Peca peca;
  const _Foto({required this.peca});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: peca.foto != null
                ? Image.memory(peca.foto!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    gaplessPlayback: true)
                : Container(
                    width: 64,
                    height: 64,
                    color: AppColors.surfaceContainerHighest,
                    child: const Icon(Icons.build_outlined,
                        color: AppColors.onSurfaceVariant),
                  ),
          ),
          if (peca.instalada)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2ECC71),
                  border: Border.all(color: AppColors.surfaceContainer),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
