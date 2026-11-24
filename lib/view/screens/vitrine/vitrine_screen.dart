import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/manage_auth/auth_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/trackmod_app_bar.dart';

/// Modificação de demonstração exibida na vitrine pública.
class _ModDemo {
  final String nome;
  final String detalhe;
  final IconData icone;
  const _ModDemo(this.nome, this.detalhe, this.icone);
}

const _mods = <_ModDemo>[
  _ModDemo('Intercooler Alta Perf.', 'HKS Type R', Icons.local_fire_department),
  _ModDemo('Rodas Forjadas 18"', 'Volk TE37', Icons.tire_repair),
  _ModDemo('Suspensão a Ar Inteligente', 'AirLift Performance 3P', Icons.tune),
  _ModDemo('Turbina Híbrida', 'Garrett GTX3582R', Icons.air),
  _ModDemo('Escape Esportivo 3"', 'HKS Hi-Power', Icons.volume_up),
];

/// Vitrine pública: carro de demonstração + convite para entrar.
/// O convite (botão Entrar / Cadastrar) some quando o usuário está logado.
class VitrineScreen extends StatelessWidget {
  final VoidCallback onEntrar;
  const VitrineScreen({super.key, required this.onEntrar});

  void _verTodas(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text('TODAS AS MODIFICAÇÕES', style: AppText.label()),
            const SizedBox(height: 8),
            for (final m in _mods)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _IconeRedondo(m.icone),
                title: Text(m.nome),
                subtitle: Text(m.detalhe, style: AppText.label(size: 12)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrackModAppBar(titulo: 'Vitrine'),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, auth) {
          final logado = auth is Authenticated;
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const _Hero(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Modificações', style: AppText.headline(size: 22)),
                        TextButton(
                          onPressed: () => _verTodas(context),
                          child: Text('VER TODAS',
                              style: AppText.label(
                                  size: 13, color: AppColors.racingRed)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _CardMod(mod: _mods[0], azul: true)),
                        const SizedBox(width: 16),
                        Expanded(child: _CardMod(mod: _mods[1], azul: false)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _CardLargo(mod: _mods[2]),
                    // Convite só para visitantes
                    if (!logado) ...[
                      const SizedBox(height: 24),
                      _ConviteEntrar(onEntrar: onEntrar),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Foto de destaque. Salve a imagem em assets/images/drift_master.jpg.
/// Se o arquivo não existir, aparece um degradê no lugar (o app não quebra).
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/drift_master.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, erro, stack) => const _HeroSemFoto(),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00131313), Color(0x99131313), Color(0xFF131313)],
                stops: [0.3, 0.7, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0x33FFB3B1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('PROJETO EM DESTAQUE',
                          style: AppText.label(
                              size: 12, color: AppColors.primary)),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.speed, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text('850 HP',
                        style: AppText.label(
                            size: 13, color: AppColors.secondary)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Project Drift Master', style: AppText.headline(size: 28)),
                const SizedBox(height: 8),
                Text(
                  'Construído para dominar as pistas. Uma obra-prima de '
                  'engenharia focada em torque absurdo e controle direcional '
                  'extremo.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSemFoto extends StatelessWidget {
  const _HeroSemFoto();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B4E6E), Color(0xFF131313)],
        ),
      ),
      child: Center(
        child: Icon(Icons.directions_car, size: 96, color: Color(0x33FFFFFF)),
      ),
    );
  }
}

class _IconeRedondo extends StatelessWidget {
  final IconData icone;
  final bool azul;
  const _IconeRedondo(this.icone, {this.azul = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: azul ? AppColors.secondaryContainer : AppColors.tertiaryContainer,
      ),
      child: Icon(icone,
          size: 22,
          color: azul ? AppColors.secondary : const Color(0xFF002F31)),
    );
  }
}

class _CardMod extends StatelessWidget {
  final _ModDemo mod;
  final bool azul;
  const _CardMod({required this.mod, required this.azul});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconeRedondo(mod.icone, azul: azul),
          const SizedBox(height: 12),
          Text(
            mod.nome,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.label(size: 14, color: AppColors.onSurface)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            mod.detalhe,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.label(size: 11),
          ),
        ],
      ),
    );
  }
}

class _CardLargo extends StatelessWidget {
  final _ModDemo mod;
  const _CardLargo({required this.mod});

  void _abrirDetalhes(BuildContext context) {
    bool modoPista = false;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final psiDianteira = modoPista ? '55 PSI' : '40 PSI';
          final psiTraseira = modoPista ? '50 PSI' : '35 PSI';
          final altura = modoPista ? '20 MM' : '55 MM';
          final textoBotao = modoPista
              ? 'DESATIVAR MODO PISTA'
              : 'ATIVAR MODO PISTA (LOW RIDE)';

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(mod.icone, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mod.nome, style: AppText.headline(size: 16)),
                            Text(
                              modoPista ? 'Modo Pista Ativo 🏎️' : mod.detalhe,
                              style: AppText.label(
                                size: 12,
                                color: modoPista
                                    ? AppColors.racingRed
                                    : AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.surfaceContainerHighest),
                  const SizedBox(height: 12),
                  Text('TELEMETRIA DA SUSPENSÃO A AR',
                      style: AppText.label(size: 11)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _itemTelemetria('DIANTEIRA', psiDianteira, Icons.tune),
                      _itemTelemetria('TRASEIRA', psiTraseira, Icons.tune),
                      _itemTelemetria('ALTURA', altura, Icons.height),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setModalState(() => modoPista = !modoPista);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 2),
                          content: Text(
                            modoPista
                                ? '⚡ Suspensão rebaixada: 20mm (Modo Pista Ativado!)'
                                : '🚗 Suspensão elevada: 55mm (Modo Rua Restaurado)',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: modoPista
                          ? AppColors.racingRed
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(modoPista ? Icons.check_circle : Icons.speed),
                    label: Text(textoBotao),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _itemTelemetria(String rotulo, String valor, IconData icone) {
    return Column(
      children: [
        Icon(icone, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(valor,
            style: AppText.headline(size: 16, color: AppColors.onSurface)),
        Text(rotulo, style: AppText.label(size: 10)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(12);
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: raio,
      child: InkWell(
        borderRadius: raio,
        onTap: () => _abrirDetalhes(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(mod.icone, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mod.nome,
                      style: AppText.label(size: 14, color: AppColors.onSurface)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(mod.detalhe, style: AppText.label(size: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConviteEntrar extends StatelessWidget {
  final VoidCallback onEntrar;
  const _ConviteEntrar({required this.onEntrar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text('Pronto para montar sua garagem?',
              textAlign: TextAlign.center,
              style: AppText.label(size: 15, color: AppColors.onSurface)
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Junte-se à comunidade TrackMod.',
              textAlign: TextAlign.center, style: AppText.label(size: 12)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onEntrar,
            icon: const Icon(Icons.arrow_forward, size: 18),
            iconAlignment: IconAlignment.end,
            label: const Text('ENTRAR / CADASTRAR'),
          ),
        ],
      ),
    );
  }
}
