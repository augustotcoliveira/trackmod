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
                    const SizedBox(height: 32),
                    
                    // Projetos da Comunidade
                    Text('Projetos da Comunidade', style: AppText.headline(size: 22)),
                    const SizedBox(height: 12),
                    const _CarrosselProjetos(),
                    const SizedBox(height: 32),

                    // Convite só para visitantes
                    if (!logado) ...[
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

// -----------------------------------------------------------------------------
// SEÇÃO: PROJETOS DA COMUNIDADE
// -----------------------------------------------------------------------------

class _ProjetoComunidade {
  final String nome;
  final String piloto;
  final String potencia;
  final String imageUrl;
  final List<String> mods;

  const _ProjetoComunidade(this.nome, this.piloto, this.potencia, this.imageUrl, this.mods);
}

const _projetos = [
  _ProjetoComunidade(
    'Skyline GT-R R34',
    'Lucas S.',
    '720 HP',
    'https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?q=80&w=600&auto=format&fit=crop',
    ['Turbina Single Precision 6266', 'Módulo Haltech Elite', 'Escape Invidia Titanium']
  ),
  _ProjetoComunidade(
    'Porsche 911 GT3 RS',
    'Rafael M.',
    '525 HP',
    'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?q=80&w=600&auto=format&fit=crop',
    ['Mantecal Akrapovic', 'Filtro BMC', 'Pastilhas Pagid RSL29']
  ),
  _ProjetoComunidade(
    'Golf GTI Mk7.5',
    'Bruna K.',
    '380 HP',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRQovmsnXaHYhlw8YplZtLoSx3j7m9dXj-CXw_UKdJUR4l43cEmQtNNfJTX&s=10',
    ['Remap Stage 3', 'Turbina IS38', 'Intercooler Wagner Tuning']
  ),
  _ProjetoComunidade(
    'Civic Type R FL5',
    'Thiago C.',
    '410 HP',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoM1xr_0O6Fd-FtZMVV2D8OCHrJ-zRlboZKUYgGGnixZNIufMqFPrdU2yH&s=10',
    ['Intake Eventuri', 'Hondata FlashPro', 'Rodas Spoon SW388']
  ),
];

class _CarrosselProjetos extends StatelessWidget {
  const _CarrosselProjetos();

  void _abrirDetalhes(BuildContext context, _ProjetoComunidade projeto) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(0),
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(projeto.imageUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(projeto.nome, style: AppText.headline(size: 22)),
                      Text(projeto.potencia, style: AppText.headline(size: 18, color: AppColors.secondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Piloto: ${projeto.piloto}', style: AppText.label(size: 12)),
                  const SizedBox(height: 24),
                  Text('LISTA DE MODIFICAÇÕES', style: AppText.label(size: 11)),
                  const SizedBox(height: 12),
                  for (final mod in projeto.mods)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(mod, style: AppText.body(size: 14))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                      label: const Text('FECHAR'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _projetos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final p = _projetos[index];
          return GestureDetector(
            onTap: () => _abrirDetalhes(context, p),
            child: Container(
              width: 160,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.network(p.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.nome, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(size: 14).copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(p.potencia, style: AppText.label(size: 11, color: AppColors.secondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
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
        ],
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
