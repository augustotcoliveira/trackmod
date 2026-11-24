import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Container padrão (superfície escura com cantos arredondados).
class Painel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const Painel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
