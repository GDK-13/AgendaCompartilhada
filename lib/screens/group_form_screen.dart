import 'package:flutter/material.dart';

import '../theme/agenda_theme.dart';
import '../widgets/agenda_widgets.dart';

class GroupFormScreen extends StatelessWidget {
  const GroupFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      header: ScreenHeader(
        titulo: 'Criar grupo',
        subtitulo: 'Tela pronta para receber sua lógica de Supabase depois.',
        leading: RoundIconButton(
          icone: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context),
        ),
      ),
      children: [
        const SizedBox(height: 20),
        const GlassCard(
          child: Column(
            children: [
              InsetField(
                label: 'Nome do grupo',
                hint: 'Exemplo: Trabalho PPDM',
              ),
              SizedBox(height: 16),
              InsetField(
                label: 'Descrição',
                hint: 'Descrição opcional',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Criar visualmente',
          icone: Icons.group_add_outlined,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 12),
        Text(
          'Nenhum grupo é persistido nesta versão.',
          textAlign: TextAlign.center,
          style: AgendaText.corpoSuave(t),
        ),
      ],
    );
  }
}
