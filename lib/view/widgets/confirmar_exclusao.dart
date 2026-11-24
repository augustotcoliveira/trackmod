import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/peca.dart';
import '../../logic/manage_garagem/manage_garagem_bloc.dart';
import '../theme/app_theme.dart';

/// Mostra um Dialog de confirmação e, se o usuário aceitar, remove a peça
/// e avisa com um SnackBar. Retorna true quando a peça foi removida.
Future<bool> confirmarExclusao(BuildContext context, Peca peca) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surfaceContainerHigh,
      title: const Text('Remover peça?'),
      content: Text(
        '"${peca.nome}" será removida do seu inventário.',
        style: AppText.body(color: AppColors.onSurfaceVariant),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Remover',
              style: TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );

  if (confirmou != true || !context.mounted) return false;

  context.read<ManageGaragemBloc>().add(DeletePeca(peca.id!));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${peca.nome} removida do inventário')),
  );
  return true;
}
