import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/agenda_theme.dart';
import '../widgets/agenda_widgets.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _lembrete = true;

  Future<void> _confirmarExclusao() async {
    final t = context.tokens;

    final excluir = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      barrierColor: t.scrim,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GlassCard(
                    forte: true,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: t.estadoErroSuave,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '!',
                            style: TextStyle(
                              color: t.estadoErro,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Excluir compromisso?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: t.textoPrincipal,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'O lembrete e a ocupação nos grupos também serão removidos.',
                          textAlign: TextAlign.center,
                          style: AgendaText.corpoSuave(t),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: GlassButton(
                                label: 'Cancelar',
                                onPressed: () => Navigator.pop(
                                  dialogContext,
                                  false,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: PrimaryButton(
                                label: 'Excluir',
                                perigo: true,
                                onPressed: () => Navigator.pop(
                                  dialogContext,
                                  true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (excluir == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      children: [
        Row(
          children: [
            RoundIconButton(
              icone: Icons.chevron_left_rounded,
              onTap: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                'Detalhes',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 64,
                    decoration: BoxDecoration(
                      color: t.membroB,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aula de Mobile',
                          style: TextStyle(
                            color: t.textoPrincipal,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Quinta, 1 de outubro',
                          style: AgendaText.corpoSuave(t),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Divider(color: t.linha),
              const SizedBox(height: 16),
              Text('HORÁRIO', style: AgendaText.rotulo(t)),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '10:30 – 12:00',
                      style: TextStyle(
                        color: t.textoPrincipal,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text('1 h 30 min', style: AgendaText.corpoSuave(t)),
                ],
              ),
              const SizedBox(height: 22),
              Text('LEMBRETE LOCAL', style: AgendaText.rotulo(t)),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hoje às 10:00 · 30 min antes',
                      style: AgendaText.corpo(t),
                    ),
                  ),
                  PhysicalToggle(
                    valor: _lembrete,
                    onChanged: (valor) {
                      setState(() => _lembrete = valor);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text('VISIBILIDADE', style: AgendaText.rotulo(t)),
              const SizedBox(height: 5),
              Text(
                'Membros veem só "Ocupado" e o horário',
                style: AgendaText.corpo(t),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        PrimaryButton(
          label: 'Editar compromisso',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.eventForm),
        ),
        const SizedBox(height: 14),
        GlassButton(
          label: 'Excluir compromisso',
          cor: t.estadoErro,
          onPressed: _confirmarExclusao,
        ),
      ],
    );
  }
}
