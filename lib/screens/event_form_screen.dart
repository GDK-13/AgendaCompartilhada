import 'package:flutter/material.dart';

import '../theme/agenda_theme.dart';
import '../widgets/agenda_widgets.dart';

class EventFormScreen extends StatelessWidget {
  const EventFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      header: ScreenHeader(
        titulo: 'Novo compromisso',
        subtitulo: 'Preencha apenas a interface. O salvamento será implementado depois.',
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
              InsetField(label: 'Título', hint: 'Exemplo: Reunião'),
              SizedBox(height: 16),
              InsetField(label: 'Descrição', hint: 'Descrição opcional'),
              SizedBox(height: 16),
              InsetField(label: 'Data', hint: '08/10/2026'),
              SizedBox(height: 16),
              InsetField(label: 'Horário', hint: '14:00'),
              SizedBox(height: 16),
              InsetField(label: 'Lembrete', hint: '30 minutos antes'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Salvar visualmente',
          icone: Icons.check_rounded,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 12),
        Text(
          'Este botão só retorna para a tela anterior.',
          textAlign: TextAlign.center,
          style: AgendaText.corpoSuave(t),
        ),
      ],
    );
  }
}
