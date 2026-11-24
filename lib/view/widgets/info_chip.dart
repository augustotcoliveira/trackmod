import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Etiqueta arredondada (categoria, estado, contagem de itens etc.).
class InfoChip extends StatelessWidget {
  final String texto;
  final Color cor;
  final Color fundo;
  final IconData? icone;

  const InfoChip(
    this.texto, {
    super.key,
    this.cor = AppColors.onSurfaceVariant,
    this.fundo = AppColors.surfaceContainerHighest,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 14, color: cor),
            const SizedBox(width: 4),
          ],
          Text(texto, style: AppText.label(size: 11, color: cor)),
        ],
      ),
    );
  }
}
