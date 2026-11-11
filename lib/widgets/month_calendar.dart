import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/modelos.dart';
import '../theme/agenda_theme.dart';
import 'agenda_widgets.dart';

const _meses = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];
const _iniciais = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

/// Visão mensal da agenda. O cabeçalho é próprio (setas + "Hoje") para
/// manter o visual do app e evitar depender de locale/intl.
///
/// Os pontinhos marcam os dias com compromisso. O pai controla o dia
/// selecionado ([selecionado]) e o mês exibido ([foco]).
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.selecionado,
    required this.foco,
    required this.compromissos,
    required this.onDia,
    required this.onMes,
  });

  final DateTime selecionado;
  final DateTime foco;

  /// Compromissos que cobrem o mês exibido (e os dias vizinhos).
  final List<Compromisso> compromissos;

  final ValueChanged<DateTime> onDia;
  final ValueChanged<DateTime> onMes;

  List<Compromisso> _doDia(DateTime d) {
    final ini = DateTime(d.year, d.month, d.day);
    final fim = DateTime(d.year, d.month, d.day + 1);
    return compromissos
        .where((c) => c.inicio.isBefore(fim) && c.fim.isAfter(ini))
        .toList();
  }

  // O table_calendar entrega datas em UTC; normalizamos para o dia local.
  static DateTime _local(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final hoje = DateTime.now();
    final noMesAtual = foco.year == hoje.year && foco.month == hoje.month;
    final mostrarHoje = !noMesAtual || !DateUtils.isSameDay(selecionado, hoje);

    final numero = TextStyle(
      color: t.textoPrincipal,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
      radius: 26,
      child: Column(
        children: [
          Row(
            children: [
              _Seta(
                icone: Icons.chevron_left_rounded,
                onTap: () => onMes(DateTime(foco.year, foco.month - 1, 1)),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        '${_meses[foco.month - 1]} ${foco.year}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: t.textoPrincipal,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (mostrarHoje) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onDia(_local(DateTime.now())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: t.acentoBase.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Hoje',
                            style: TextStyle(
                              color: t.acentoBase,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _Seta(
                icone: Icons.chevron_right_rounded,
                onTap: () => onMes(DateTime(foco.year, foco.month + 1, 1)),
              ),
            ],
          ),
          TableCalendar<Compromisso>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: foco,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            // Só swipe horizontal: o vertical pertence à rolagem da tela.
            availableGestures: AvailableGestures.horizontalSwipe,
            headerVisible: false,
            rowHeight: 50,
            daysOfWeekHeight: 28,
            selectedDayPredicate: (d) => DateUtils.isSameDay(d, selecionado),
            eventLoader: _doDia,
            onDaySelected: (sel, _) => onDia(_local(sel)),
            onPageChanged: (novo) => onMes(_local(novo)),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: true,
              cellMargin: const EdgeInsets.all(5),
              defaultTextStyle: numero,
              weekendTextStyle: numero,
              outsideTextStyle: numero.copyWith(color: t.textoFraco),
              todayTextStyle: numero.copyWith(
                color: t.acentoBase,
                fontWeight: FontWeight.w800,
              ),
              todayDecoration: BoxDecoration(
                color: t.acentoBase.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: numero.copyWith(
                color: t.acentoSobre,
                fontWeight: FontWeight.w800,
              ),
              selectedDecoration: BoxDecoration(
                color: t.acentoBase,
                shape: BoxShape.circle,
                boxShadow: t.sombraBotao,
              ),
            ),
            calendarBuilders: CalendarBuilders<Compromisso>(
              dowBuilder: (context, dia) => Center(
                child: Text(
                  _iniciais[dia.weekday % 7],
                  style: TextStyle(
                    color: t.textoSuave,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              markerBuilder: (context, dia, eventos) {
                if (eventos.isEmpty) return null;
                final sel = DateUtils.isSameDay(dia, selecionado);
                final cor = sel ? t.acentoSobre : t.acentoBase;
                return Positioned(
                  bottom: 7,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < math.min(eventos.length, 3); i++)
                        Container(
                          width: 4.5,
                          height: 4.5,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration:
                              BoxDecoration(color: cor, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Seta extends StatelessWidget {
  const _Seta({required this.icone, required this.onTap});

  final IconData icone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icone, size: 26, color: t.textoSuave),
      ),
    );
  }
}