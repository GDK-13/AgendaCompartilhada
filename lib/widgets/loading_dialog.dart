import 'package:flutter/material.dart';

import '../theme/agenda_theme.dart';
import 'agenda_widgets.dart';

/// Mostra um pop-up de loading bloqueante enquanto [tarefa] roda e o fecha
/// ao terminar (com sucesso ou erro). O erro é repassado para quem chamou.
///
/// Uso:
///   await comLoading(context, () => Service.algo(), texto: 'Salvando...');
Future<T> comLoading<T>(
  BuildContext context,
  Future<T> Function() tarefa, {
  String texto = 'Aguarde...',
}) async {
  final t = context.tokens;
  final nav = Navigator.of(context, rootNavigator: true);

  showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: t.scrim,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (_, __, ___) => PopScope(
      canPop: false,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GlassCard(
            forte: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(width: 16),
                Text(texto, style: AgendaText.corpo(t)),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  try {
    return await tarefa();
  } finally {
    if (nav.mounted) nav.pop();
  }
}
