import 'package:flutter/material.dart';

import '../controllers/theme_controller.dart';
import '../models/modelos.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/compromisso_service.dart';
import '../services/convite_service.dart';
import '../services/erros.dart';
import '../services/grupo_service.dart';
import '../services/notificacao_service.dart';
import '../theme/agenda_theme.dart';
import '../widgets/agenda_widgets.dart';
import '../widgets/loading_dialog.dart';
import '../widgets/month_calendar.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.themeController,
  });

  final ThemeController themeController;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  DateTime _dia = DateTime.now();
  List<Compromisso> _compromissos = [];
  List<Grupo> _grupos = [];
  bool _carregando = true;
  String? _erro;

  // Visão mensal (table_calendar).
  bool _mensal = false;
  DateTime _mesFoco = DateTime.now();
  List<Compromisso> _compromissosMes = [];

  int _reqId = 0;
  int _reqMes = 0;

  @override
  void initState() {
    super.initState();
    _recarregar();
    _carregarMes();
    _prepararLembretes();
  }

  // Compromissos do mês exibido, só para os marcadores do calendário.
  Future<void> _carregarMes() async {
    final id = ++_reqMes;
    try {
      final r = await CompromissoService.doMes(_mesFoco);
      if (!mounted || id != _reqMes) return;
      setState(() => _compromissosMes = r);
    } catch (e) {
      debugPrint('Erro ao carregar o mês: $e');
    }
  }

  void _mudarMes(DateTime m) {
    if (m.year == _mesFoco.year && m.month == _mesFoco.month) return;
    setState(() => _mesFoco = m);
    _carregarMes();
  }

  // Pede permissão e refaz os lembretes dos próximos 30 dias.
  Future<void> _prepararLembretes() async {
    await NotificacaoService.pedirPermissao();
    try {
      final agora = DateTime.now();
      final prox = await CompromissoService.doPeriodo(
        agora,
        agora.add(const Duration(days: 30)),
      );
      List<Grupo> grupos = const [];
      try {
        grupos = await GrupoService.listar();
      } catch (_) {}
      await NotificacaoService.sincronizar(prox, grupos: grupos);
    } catch (e) {
      debugPrint('Erro ao preparar lembretes: $e');
    }
    await _verificarAvisos();
  }

  bool _verificandoAvisos = false;

  // Avisos de grupo gerados no servidor (alguém saiu, grupo será excluído...).
  // Viram notificação local na hora e uma mensagem na tela. Só chegam quando o
  // app é aberto/atualizado (não há push com o app fechado).
  Future<void> _verificarAvisos() async {
    if (_verificandoAvisos) return;
    _verificandoAvisos = true;
    try {
      final avisos = await GrupoService.avisosPendentes();
      if (avisos.isEmpty) return;
      for (final a in avisos) {
        await NotificacaoService.mostrarAgora(a.id, a.titulo, a.mensagem);
      }
      await GrupoService.marcarAvisosLidos(avisos.map((a) => a.id).toList());
      if (!mounted) return;
      final texto = avisos.length == 1
          ? '${avisos.first.titulo}: ${avisos.first.mensagem}'
          : '${avisos.length} novos avisos de grupos.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
    } catch (e) {
      debugPrint('Erro ao buscar avisos de grupo: $e');
    } finally {
      _verificandoAvisos = false;
    }
  }

  Future<void> _recarregar() async {
    final id = ++_reqId;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final r = await Future.wait([
        CompromissoService.doDia(_dia),
        GrupoService.listar(),
      ]);
      if (!mounted || id != _reqId) return;
      setState(() {
        _compromissos = r[0] as List<Compromisso>;
        _grupos = r[1] as List<Grupo>;
      });
      for (final g in _grupos) {
        NotificacaoService.agendarExclusaoGrupo(g);
      }
      _verificarAvisos();
    } catch (e) {
      if (mounted && id == _reqId) setState(() => _erro = traduzirErro(e));
    } finally {
      if (mounted && id == _reqId) setState(() => _carregando = false);
    }
  }

  // Abre uma rota e recarrega se ela devolveu true.
  Future<void> _abrir(String rota, {Object? args}) async {
    final mudou = await Navigator.pushNamed(context, rota, arguments: args);
    if (mudou == true) {
      _recarregar();
      _carregarMes();
    }
  }

  void _mudarDia(DateTime d) {
    _dia = d;
    final mudouMes = d.year != _mesFoco.year || d.month != _mesFoco.month;
    if (mudouMes) _mesFoco = d;
    _recarregar();
    if (mudouMes) _carregarMes();
  }

  Future<void> _entrarComCodigo() async {
    final ctrl = TextEditingController();
    final codigo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Entrar com código'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'Ex.: A1B2C3D4'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
    if (codigo == null || codigo.trim().isEmpty) return;
    // Extrai o código ANTES de pôr em maiúsculas: se o usuário colou o link
    // ou a mensagem inteira, o "agenda://convite?codigo=" precisa continuar
    // em minúsculas para ser reconhecido.
    final puro = ConviteService.extrairCodigo(codigo) ?? codigo.trim();
    try {
      if (!mounted) return;
      await comLoading(
        context,
        () => GrupoService.entrar(puro.toUpperCase()),
        texto: 'Entrando no grupo...',
      );
      _recarregar();
    } catch (e) {
      debugPrint('Erro ao entrar no grupo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(traduzirErro(e))));
      }
    }
  }

  void _changeTab(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _index,
      children: [
        _AgendaScreen(
          onTab: _changeTab,
          dia: _dia,
          compromissos: _compromissos,
          carregando: _carregando,
          erro: _erro,
          onRetry: _recarregar,
          onDia: _mudarDia,
          mensal: _mensal,
          mesFoco: _mesFoco,
          compromissosMes: _compromissosMes,
          onVisao: (v) => setState(() => _mensal = v),
          onMes: _mudarMes,
          onNovo: () => _abrir(AppRoutes.eventForm),
          onDetalhe: (c) => _abrir(AppRoutes.eventDetail, args: c),
        ),
        _GroupsScreen(
          onTab: _changeTab,
          grupos: _grupos,
          carregando: _carregando,
          onNovo: () => _abrir(AppRoutes.groupForm),
          onEntrar: _entrarComCodigo,
          onAbrir: (g) => _abrir(AppRoutes.groupDetail, args: g),
        ),
        _FreeSlotsScreen(onTab: _changeTab, grupos: _grupos),
        _ProfileScreen(
          onTab: _changeTab,
          onSettings: () => Navigator.pushNamed(context, AppRoutes.settings),
          onLogout: () async {
            try {
              await NotificacaoService.cancelarTodas();
              await AuthService.sair();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(traduzirErro(e))));
              }
            }
          },
        ),
      ],
    );
  }
}

const _diasSemana = [
  'Domingo',
  'Segunda',
  'Terça',
  'Quarta',
  'Quinta',
  'Sexta',
  'Sábado',
];
const _meses = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

class _AgendaScreen extends StatelessWidget {
  const _AgendaScreen({
    required this.onTab,
    required this.dia,
    required this.compromissos,
    required this.carregando,
    required this.erro,
    required this.onRetry,
    required this.onDia,
    required this.mensal,
    required this.mesFoco,
    required this.compromissosMes,
    required this.onVisao,
    required this.onMes,
    required this.onNovo,
    required this.onDetalhe,
  });

  final ValueChanged<int> onTab;
  final DateTime dia;
  final List<Compromisso> compromissos;
  final bool carregando;
  final String? erro;
  final VoidCallback onRetry;
  final ValueChanged<DateTime> onDia;
  final VoidCallback onNovo;
  final ValueChanged<Compromisso> onDetalhe;
  final bool mensal;
  final DateTime mesFoco;
  final List<Compromisso> compromissosMes;
  final ValueChanged<bool> onVisao;
  final ValueChanged<DateTime> onMes;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      tabIndex: 0,
      onTab: onTab,
      floatingAction: _AgendaFab(onTap: onNovo),
      children: [
        Text(
          '${_diasSemana[dia.weekday % 7]}, ${dia.day} de ${_meses[dia.month - 1]}',
          style: AgendaText.corpoSuave(t),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text('Minha agenda', style: AgendaText.titulo(t)),
            ),
            MemberAvatar(nome: AuthService.nome, cor: t.membroA, tamanho: 48),
          ],
        ),
        const SizedBox(height: 18),
        if (erro != null) ...[
          StatusBanner(
            texto: erro!,
            tipo: BannerTipo.erro,
            acao: 'Tentar de novo',
            onAcao: onRetry,
          ),
          const SizedBox(height: 12),
        ],
        _VisaoToggle(mensal: mensal, onChanged: onVisao),
        const SizedBox(height: 12),
        if (mensal)
          MonthCalendar(
            selecionado: dia,
            foco: mesFoco,
            compromissos: compromissosMes,
            onDia: onDia,
            onMes: onMes,
          )
        else
          _WeekStrip(dia: dia, onDia: onDia),
        const SizedBox(height: 16),
        if (carregando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (compromissos.isEmpty)
          const EmptyState(
            icone: Icons.event_available_outlined,
            titulo: 'Dia livre',
            texto: 'Você não tem compromissos neste dia.',
          )
        else
          _DayTimeline(
            dia: dia,
            compromissos: compromissos,
            onEventTap: onDetalhe,
          ),
      ],
    );
  }
}

/// Alterna entre a faixa semanal e o calendário mensal.
class _VisaoToggle extends StatelessWidget {
  const _VisaoToggle({required this.mensal, required this.onChanged});

  final bool mensal;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    Widget opcao(String label, bool ativo, bool valor) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(valor),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: ativo ? t.acentoBase : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: ativo ? t.acentoSobre : t.textoSuave,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: t.vidroNormal,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: t.vidroBorda),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            opcao('Semana', !mensal, false),
            opcao('Mês', mensal, true),
          ],
        ),
      ),
    );
  }
}

class _AgendaFab extends StatelessWidget {
  const _AgendaFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: t.acentoBase,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          boxShadow: t.sombraBotao,
        ),
        child: Icon(Icons.add_rounded, size: 32, color: t.acentoSobre),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.dia, required this.onDia});

  final DateTime dia;
  final ValueChanged<DateTime> onDia;

  static String _mesLongo(int m) {
    final s = _meses[m - 1];
    return s[0].toUpperCase() + s.substring(1);
  }

  static String _mesCurto(int m) => _mesLongo(m).substring(0, 3);

  static String _titulo(DateTime ini, DateTime fim) {
    if (ini.year == fim.year && ini.month == fim.month) {
      return '${_mesLongo(ini.month)} ${ini.year}';
    }
    if (ini.year == fim.year) {
      return '${_mesCurto(ini.month)} – ${_mesCurto(fim.month)} ${ini.year}';
    }
    return '${_mesCurto(ini.month)} ${ini.year} – ${_mesCurto(fim.month)} ${fim.year}';
  }

  void _semana(int n) => onDia(DateTime(dia.year, dia.month, dia.day + 7 * n));

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    const labels = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    final hoje = DateTime.now();
    final ehHoje = DateUtils.isSameDay(dia, hoje);
    final domingo = DateTime(dia.year, dia.month, dia.day - (dia.weekday % 7));
    final dias = [
      for (var i = 0; i < 7; i++)
        DateTime(domingo.year, domingo.month, domingo.day + i),
    ];

    return GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v < -200) _semana(1);
        if (v > 200) _semana(-1);
      },
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
        radius: 26,
        child: Column(
          children: [
            Row(
              children: [
                _SetaSemana(
                  icone: Icons.chevron_left_rounded,
                  onTap: () => _semana(-1),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _titulo(dias.first, dias.last),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: t.textoPrincipal,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!ehHoje) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onDia(DateTime.now()),
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
                _SetaSemana(
                  icone: Icons.chevron_right_rounded,
                  onTap: () => _semana(1),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onDia(dias[i]),
                      child: SizedBox(
                        height: 68,
                        child: Builder(builder: (context) {
                          final sel = DateUtils.isSameDay(dias[i], dia);
                          final eHoje = DateUtils.isSameDay(dias[i], hoje);
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              if (sel)
                                Container(
                                  width: 42,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: t.acentoBase,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: t.sombraBotao,
                                  ),
                                ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    labels[i],
                                    style: TextStyle(
                                      color: sel ? t.acentoSobre : t.textoSuave,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${dias[i].day}',
                                    style: TextStyle(
                                      color: sel
                                          ? t.acentoSobre
                                          : t.textoPrincipal,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              // marca o dia de hoje quando não está selecionado
                              if (eHoje && !sel)
                                Positioned(
                                  bottom: 1,
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: t.acentoBase,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SetaSemana extends StatelessWidget {
  const _SetaSemana({required this.icone, required this.onTap});

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

class _DayTimeline extends StatelessWidget {
  const _DayTimeline({
    required this.dia,
    required this.compromissos,
    required this.onEventTap,
  });

  final DateTime dia;
  final List<Compromisso> compromissos;
  final ValueChanged<Compromisso> onEventTap;

  static const double hourHeight = 52;
  static const double leftGutter = 52;

  static double _hora(DateTime d) => d.hour + d.minute / 60;

  // Evento que começou em um dia anterior aparece desde 00:00 neste dia.
  double _horaIni(Compromisso c) =>
      DateUtils.isSameDay(c.inicio, dia) ? _hora(c.inicio) : 0.0;

  // Evento que termina em um dia posterior vai até 24:00 neste dia.
  double _horaFim(Compromisso c) =>
      DateUtils.isSameDay(c.fim, dia) ? _hora(c.fim) : 24.0;

  static String _hm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final cores = [
      (t.membroA, t.eventoASuave),
      (t.membroB, t.eventoBSuave),
      (t.eventoC, t.eventoCSuave),
    ];

    var inicioH = 8;
    var fimH = 16;
    for (final c in compromissos) {
      final i = _horaIni(c).floor();
      final f = _horaFim(c).ceil();
      if (i < inicioH) inicioH = i;
      if (f > fimH) fimH = f;
    }

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      radius: 28,
      child: SizedBox(
        height: hourHeight * (fimH - inicioH) + 18,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final eventWidth = constraints.maxWidth - leftGutter - 4;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (var h = inicioH; h <= fimH; h++) ...[
                  Positioned(
                    left: 0,
                    top: (h - inicioH) * hourHeight - 5,
                    width: 44,
                    child: Text(
                      '${(h % 24).toString().padLeft(2, '0')}:00',
                      style: TextStyle(
                        color: t.textoSuave,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    left: leftGutter,
                    right: 0,
                    top: (h - inicioH) * hourHeight,
                    child: Container(height: 1, color: t.linha),
                  ),
                ],
                for (var i = 0; i < compromissos.length; i++)
                  _TimelineEvent(
                    top: (_horaIni(compromissos[i]) - inicioH) * hourHeight,
                    height: ((_horaFim(compromissos[i]) -
                                    _horaIni(compromissos[i])) *
                                hourHeight -
                            6)
                        .clamp(34.0, double.infinity),
                    width: eventWidth,
                    title: compromissos[i].titulo,
                    subtitle:
                        '${_hm(compromissos[i].inicio)} – ${_hm(compromissos[i].fim)}',
                    color: cores[i % cores.length].$1,
                    softColor: cores[i % cores.length].$2,
                    onTap: () => onEventTap(compromissos[i]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({
    required this.top,
    required this.height,
    required this.width,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.softColor,
    required this.onTap,
  });

  final double top;
  final double height;
  final double width;
  final String title;
  final String subtitle;
  final Color color;
  final Color softColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // Abaixo disso título + horário empilhados não cabem (~38px de conteúdo).
    final compacto = height < 46;
    return Positioned(
      left: _DayTimeline.leftGutter + 4,
      top: top + 3,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: softColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: t.vidroBorda),
            boxShadow: [
              BoxShadow(
                color: t.relevoSombraCurta,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: compacto
                    // Evento curto: título e horário na mesma linha para
                    // não estourar a altura do bloco.
                    ? Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: t.textoPrincipal,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            subtitle,
                            maxLines: 1,
                            style: TextStyle(
                              color: t.textoSuave,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: t.textoPrincipal,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: t.textoSuave,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupsScreen extends StatelessWidget {
  const _GroupsScreen({
    required this.onTab,
    required this.grupos,
    required this.carregando,
    required this.onNovo,
    required this.onEntrar,
    required this.onAbrir,
  });

  final ValueChanged<int> onTab;
  final List<Grupo> grupos;
  final bool carregando;
  final VoidCallback onNovo;
  final VoidCallback onEntrar;
  final ValueChanged<Grupo> onAbrir;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final cores = [t.membroA, t.membroB];

    return ScreenScaffold(
      tabIndex: 1,
      onTab: onTab,
      header: const ScreenHeader(
        titulo: 'Grupos',
        subtitulo: 'Agendas compartilhadas com outras pessoas',
      ),
      children: [
        const SizedBox(height: 20),
        if (carregando && grupos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (grupos.isEmpty)
          const EmptyState(
            icone: Icons.group_outlined,
            titulo: 'Nenhum grupo ainda',
            texto: 'Crie um grupo ou entre com um código.',
          )
        else
          for (var i = 0; i < grupos.length; i++) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onAbrir(grupos[i]),
              child: _GroupTile(
                title: grupos[i].nome,
                subtitle:
                    '${grupos[i].membros} membro(s)  ·  código ${grupos[i].codigo}'
                    '${grupos[i].excluiEm == null ? '' : '\nSerá excluído em ${grupos[i].excluiEmTexto}'}',
                color: cores[i % cores.length],
              ),
            ),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 8),
        PrimaryButton(
          label: 'Criar grupo',
          icone: Icons.group_add_outlined,
          onPressed: onNovo,
        ),
        const SizedBox(height: 12),
        GlassButton(
          label: 'Entrar com código',
          onPressed: onEntrar,
        ),
      ],
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 22,
      child: Row(
        children: [
          MemberAvatar(nome: title, cor: color, tamanho: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AgendaText.corpo(t)),
                const SizedBox(height: 3),
                Text(subtitle, style: AgendaText.corpoSuave(t)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: t.textoFraco),
        ],
      ),
    );
  }
}

String _hm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

class _FreeSlotsScreen extends StatefulWidget {
  const _FreeSlotsScreen({required this.onTab, required this.grupos});

  final ValueChanged<int> onTab;
  final List<Grupo> grupos;

  @override
  State<_FreeSlotsScreen> createState() => _FreeSlotsScreenState();
}

class _FreeSlotsScreenState extends State<_FreeSlotsScreen> {
  Grupo? _grupo;
  DateTime _dia = DateTime.now();
  TimeOfDay _ini = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _fim = const TimeOfDay(hour: 22, minute: 0);
  List<Intervalo>? _livres;
  List<Ocupacao> _ocupacoes = [];
  bool _buscando = false;
  String? _erro;

  // Procura o grupo escolhido pelo id na lista ATUAL. Sem isso, depois de
  // criar/entrar em um grupo a lista é recarregada com objetos novos e o
  // Dropdown quebra ("exactly one item with value").
  Grupo? get _selecionado {
    for (final x in widget.grupos) {
      if (x.id == _grupo?.id) return x;
    }
    return widget.grupos.isNotEmpty ? widget.grupos.first : null;
  }

  Future<void> _buscar() async {
    final g = _selecionado;
    if (g == null) return;
    final ini =
        DateTime(_dia.year, _dia.month, _dia.day, _ini.hour, _ini.minute);
    final fim =
        DateTime(_dia.year, _dia.month, _dia.day, _fim.hour, _fim.minute);
    if (!ini.isBefore(fim)) {
      setState(() => _erro = 'A faixa precisa terminar depois de começar.');
      return;
    }
    setState(() {
      _buscando = true;
      _erro = null;
      _livres = null;
      _ocupacoes = [];
    });
    try {
      final r = await Future.wait([
        GrupoService.horariosLivres(g.id, ini, fim),
        GrupoService.ocupacoes(g.id, ini, fim),
      ]);
      if (!mounted) return;
      setState(() {
        _grupo = g;
        _livres = r[0] as List<Intervalo>;
        _ocupacoes = r[1] as List<Ocupacao>;
      });
    } catch (e) {
      debugPrint('Erro ao buscar horários livres: $e');
      if (mounted) setState(() => _erro = traduzirErro(e));
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  String _dur(Duration d) {
    final h = d.inHours, m = d.inMinutes % 60;
    if (h == 0) return '$m min';
    return m == 0 ? '$h h' : '$h h $m min';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final g = _selecionado;

    return ScreenScaffold(
      tabIndex: 2,
      onTab: widget.onTab,
      header: const ScreenHeader(
        titulo: 'Horários livres',
        subtitulo: 'Intervalos em que todos do grupo estão livres',
      ),
      children: [
        const SizedBox(height: 20),
        if (widget.grupos.isEmpty)
          const EmptyState(
            icone: Icons.group_outlined,
            titulo: 'Sem grupo',
            texto: 'Crie ou entre em um grupo para buscar horários.',
          )
        else ...[
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButton<Grupo>(
                  isExpanded: true,
                  value: g,
                  style: AgendaText.corpo(t),
                  iconEnabledColor: t.textoSuave,
                  items: [
                    for (final x in widget.grupos)
                      DropdownMenuItem(value: x, child: Text(x.nome)),
                  ],
                  onChanged: (v) => setState(() => _grupo = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label: '${_dia.day}/${_dia.month}',
                        onPressed: () async {
                          final d = await showDatePicker(
                              context: context,
                              initialDate: _dia,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100));
                          if (d != null) setState(() => _dia = d);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlassButton(
                        label: _ini.format(context),
                        onPressed: () async {
                          final h = await showTimePicker(
                              context: context, initialTime: _ini);
                          if (h != null) setState(() => _ini = h);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlassButton(
                        label: _fim.format(context),
                        onPressed: () async {
                          final h = await showTimePicker(
                              context: context, initialTime: _fim);
                          if (h != null) setState(() => _fim = h);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: _buscando ? 'Buscando...' : 'Buscar horários',
                  onPressed: _buscando ? null : _buscar,
                ),
              ],
            ),
          ),
          if (_buscando) ...[
            const SizedBox(height: 32),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_erro != null) ...[
            const SizedBox(height: 16),
            StatusBanner(
                texto: _erro!,
                tipo: BannerTipo.erro,
                acao: 'Tentar de novo',
                onAcao: _buscar),
          ],
          if (_livres != null) ...[
            const SizedBox(height: 16),
            if (g != null && g.membros == 1)
              const InfoNote(
                  texto:
                      'Você é o único membro: o resultado mostra só a sua agenda.'), // RN09
            const SizedBox(height: 12),
            if (_livres!.isEmpty)
              const EmptyState(
                icone: Icons.event_busy_outlined,
                titulo: 'Nenhum horário em comum',
                texto: 'Tente outra faixa ou outro dia.',
              )
            else
              for (final i in _livres!) ...[
                FreeSlotCard(
                  intervalo: '${_hm(i.inicio)} até ${_hm(i.fim)}',
                  duracao: _dur(i.duracao),
                ),
                const SizedBox(height: 10),
              ],
            if (_ocupacoes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('OCUPADOS', style: AgendaText.rotulo(t)),
              const SizedBox(height: 8),
              for (final o in _ocupacoes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                      '${o.nomeMembro}: ${_hm(o.inicio)} – ${_hm(o.fim)}',
                      style: AgendaText.corpoSuave(t)),
                ),
            ],
            const SizedBox(height: 12),
            const InfoNote(
              texto:
                  'O resultado depende da agenda preenchida por cada membro.', // RN07
            ),
          ],
        ],
      ],
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen({
    required this.onTab,
    required this.onSettings,
    required this.onLogout,
  });

  final ValueChanged<int> onTab;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ScreenScaffold(
      tabIndex: 3,
      onTab: onTab,
      header: const ScreenHeader(titulo: 'Perfil'),
      children: [
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            children: [
              MemberAvatar(nome: 'Kevin', cor: t.membroA, tamanho: 72),
              const SizedBox(height: 12),
              Text(AuthService.nome, style: AgendaText.corpo(t)),
              const SizedBox(height: 3),
              Text(AuthService.email, style: AgendaText.corpoSuave(t)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSettings,
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            radius: 22,
            child: Row(
              children: [
                Icon(Icons.palette_outlined, color: t.acentoBase),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aparência', style: AgendaText.corpo(t)),
                      const SizedBox(height: 3),
                      Text(t.nome, style: AgendaText.corpoSuave(t)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: t.textoFraco),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        GlassButton(
          label: 'Sair da conta',
          onPressed: onLogout,
          cor: t.estadoErro,
        ),
      ],
    );
  }
}