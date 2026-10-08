import 'package:flutter/material.dart';

import '../theme/agenda_theme.dart';
import '../widgets/agenda_widgets.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  bool _lembrete = true;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      children: [
        Row(
          children: [
            RoundIconButton(
              icone: Icons.close_rounded,
              onTap: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                'Novo compromisso',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: t.textoPrincipal,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 22),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const InsetField(
                label: 'Título',
                valor: 'Cinema com Ana',
                hint: 'Nome do compromisso',
              ),
              const SizedBox(height: 16),
              const InsetField(
                label: 'Data',
                valor: 'sex, 2 de outubro de 2026',
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(
                    child: InsetField(
                      label: 'Início',
                      valor: '19:00',
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: InsetField(
                      label: 'Fim',
                      valor: '21:00',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: t.linha),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lembrete local', style: AgendaText.corpo(t)),
                        const SizedBox(height: 4),
                        Text(
                          'Aviso 30 minutos antes do início',
                          style: AgendaText.corpoSuave(t),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    children: [
                      PhysicalToggle(
                        valor: _lembrete,
                        onChanged: (valor) {
                          setState(() => _lembrete = valor);
                        },
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _lembrete ? 'Ligado' : 'Desligado',
                        style: TextStyle(
                          color: _lembrete ? t.estadoLivre : t.textoSuave,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const InfoNote(
          texto:
              'Só você vê o título. Os membros do grupo enxergam apenas o horário ocupado.',
        ),
        const SizedBox(height: 44),
        PrimaryButton(
          label: 'Salvar compromisso',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 14),
        GlassButton(
          label: 'Cancelar',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
