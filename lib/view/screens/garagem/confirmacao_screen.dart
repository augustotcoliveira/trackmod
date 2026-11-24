import 'package:flutter/material.dart';

import '../../../data/models/peca.dart';
import '../../theme/app_theme.dart';

/// Feedback positivo após salvar uma peça (protótipo "Peça Adicionada!").
class ConfirmacaoScreen extends StatelessWidget {
  final Peca peca;
  const ConfirmacaoScreen({super.key, required this.peca});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DETALHES DO CARRO')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerHigh,
              ),
              child: const Icon(Icons.check_circle_outline,
                  size: 96, color: AppColors.tertiary),
            ),
            const SizedBox(height: 40),
            Text('Peça Adicionada!', style: AppText.headline(size: 28)),
            const SizedBox(height: 12),
            Text(
              '${peca.nome} foi incluída na sua garagem com sucesso.',
              textAlign: TextAlign.center,
              style: AppText.body(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.garage),
              label: const Text('VOLTAR PARA A GARAGEM'),
            ),
          ],
        ),
      ),
    );
  }
}
