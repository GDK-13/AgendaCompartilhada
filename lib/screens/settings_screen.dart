import 'package:flutter/material.dart';

import '../controllers/theme_controller.dart';
import '../theme/agenda_theme.dart';
import '../widgets/agenda_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.themeController,
  });

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      header: ScreenHeader(
        titulo: 'Aparência',
        subtitulo: 'Escolha um dos cinco temas originais do projeto.',
        leading: RoundIconButton(
          icone: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context),
        ),
      ),
      children: [
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TEMAS', style: AgendaText.rotulo(t)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (var i = 0; i < AppThemes.todos.length; i++)
                    _ThemeTile(
                      theme: AppThemes.todos[i],
                      selected: AppThemes.todos[i].id == t.id,
                      onTap: () => themeController.setTheme(AppThemeId.values[i]),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const InfoNote(
          icone: Icons.palette_outlined,
          texto: 'Sua escolha de tema fica salva na sua conta e neste aparelho.',
        ),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final AgendaTokens theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = [
      theme.acentoBase,
      theme.membroB,
      theme.membroC,
      theme.estadoLivre,
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 144,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.fundoBase,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? theme.acentoBase : theme.linha,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? theme.sombraCartao : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (final color in colors)
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                const Spacer(),
                if (selected)
                  Icon(
                    Icons.check_circle,
                    size: 17,
                    color: theme.acentoBase,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              theme.nome,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.textoPrincipal,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}