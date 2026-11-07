import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/modelos.dart';
import '../services/auth_service.dart';
import '../services/erros.dart';
import '../services/grupo_service.dart';
import '../theme/agenda_theme.dart';
import '../widgets/agenda_widgets.dart';
import '../widgets/convite_dialog.dart';

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

String _hm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _dur(Duration d) {
  final h = d.inHours, m = d.inMinutes % 60;
  if (h == 0) return '$m min';
  return m == 0 ? '$h h' : '$h h $m min';
}

/// Tela de um grupo: ocupação sobreposta de cada membro (RF04 / HU04) e os
/// horários livres em comum para a faixa escolhida (RF05).
///
/// Recebe o [Grupo] como argumento da rota. Mostra somente "Ocupado" e o
/// intervalo de cada membro: nenhum título de compromisso alheio (RN03).
class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  Grupo? _grupo;
  DateTime _dia = DateTime.now();
  TimeOfDay _ini = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _fim = const TimeOfDay(hour: 22, minute: 0);

  List<Ocupacao> _ocupacoes = [];
  List<Intervalo> _livres = [];
  bool _carregando = true;
  String? _erro;
  bool _iniciado = false;

  // Cada membro mantém a mesma cor ao trocar de dia. Você é sempre o índice 0.
  final Map<String, int> _cores = {};

  // Descarta respostas antigas quando o usuário troca de dia rapidamente.
  int _reqId = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Grupo) {
      _grupo = arg;
      _cores[AuthService.uid] = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _carregar();
      });
    } else {
      _carregando = false;
    }
  }

  Future<void> _carregar() async {
    final g = _grupo;
    if (g == null) return;

    final ini = DateTime(_dia.year, _dia.month, _dia.day);
    final fim = DateTime(_dia.year, _dia.month, _dia.day + 1);
    final faixaIni =
        DateTime(_dia.year, _dia.month, _dia.day, _ini.hour, _ini.minute);
    final faixaFim =
        DateTime(_dia.year, _dia.month, _dia.day, _fim.hour, _fim.minute);

    if (!faixaIni.isBefore(faixaFim)) {
      setState(() => _erro = 'A faixa precisa terminar depois de começar.');
      return;
    }

    final id = ++_reqId;
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      // A ocupação cobre o dia inteiro; os horários livres só a faixa escolhida.
      final r = await Future.wait([
        GrupoService.ocupacoes(g.id, ini, fim),
        GrupoService.horariosLivres(g.id, faixaIni, faixaFim),
      ]);
      if (!mounted || id != _reqId) return;

      final oc = r[0] as List<Ocupacao>;
      final ordenadas = [...oc]
        ..sort((a, b) => a.nomeMembro.compareTo(b.nomeMembro));
      setState(() {
        _ocupacoes = oc;
        _livres = r[1] as List<Intervalo>;
        for (final o in ordenadas) {
          _cores.putIfAbsent(o.usuarioId, () => _cores.length);
        }
      });
    } catch (e) {
      debugPrint('Erro ao carregar grupo: $e');
      if (mounted && id == _reqId) setState(() => _erro = traduzirErro(e));
    } finally {
      if (mounted && id == _reqId) setState(() => _carregando = false);
    }
  }

  void _mudarDia(DateTime d) {
    setState(() => _dia = d);
    _carregar();
  }

  Future<void> _escolherDia() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dia,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) _mudarDia(d);
  }

  Future<void> _escolherHora(bool inicio) async {
    final h = await showTimePicker(
      context: context,
      initialTime: inicio ? _ini : _fim,
    );
    if (h == null) return;
    setState(() {
      if (inicio) {
        _ini = h;
      } else {
        _fim = h;
      }
    });
    _carregar();
  }

  // Intervalo de horas exibido: cobre a faixa pesquisada e toda ocupação.
  (int, int) _horasVisiveis() {
    final base = DateTime(_dia.year, _dia.month, _dia.day);
    var ini = math.min(8, _ini.hour);
    var fim = math.max(22, _fim.minute > 0 ? _fim.hour + 1 : _fim.hour);
    for (final o in _ocupacoes) {
      final a = _GroupTimeline.horas(o.inicio, base);
      final b = _GroupTimeline.horas(o.fim, base);
      if (b <= a) continue;
      ini = math.min(ini, a.floor());
      fim = math.max(fim, b.ceil());
    }
    return (ini.clamp(0, 23), fim.clamp(1, 24));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final g = _grupo;

    if (g == null) {
      return ScreenScaffold(
        children: [
          Row(
            children: [
              RoundIconButton(
                icone: Icons.chevron_left_rounded,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const EmptyState(
            icone: Icons.group_outlined,
            titulo: 'Grupo não encontrado',
            texto: 'Volte e abra o grupo de novo.',
          ),
        ],
      );
    }

    final (inicioH, fimH) = _horasVisiveis();

    return ScreenScaffold(
      header: ScreenHeader(
        titulo: g.nome,
        subtitulo: '${g.membros} membro(s)  ·  código ${g.codigo}',
        leading: Row(
          children: [
            RoundIconButton(
              icone: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            RoundIconButton(
              icone: Icons.ios_share_rounded,
              onTap: () => mostrarConvite(context, g),
            ),
          ],
        ),
      ),
      children: [
        const SizedBox(height: 20),
        _SeletorDia(
          dia: _dia,
          onAnterior: () =>
              _mudarDia(DateTime(_dia.year, _dia.month, _dia.day - 1)),
          onProximo: () =>
              _mudarDia(DateTime(_dia.year, _dia.month, _dia.day + 1)),
          onEscolher: _escolherDia,
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(14),
          radius: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('FAIXA PARA HORÁRIOS LIVRES', style: AgendaText.rotulo(t)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Das ${_ini.format(context)}',
                      onPressed: () => _escolherHora(true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassButton(
                      label: 'Às ${_fim.format(context)}',
                      onPressed: () => _escolherHora(false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_erro != null) ...[
          StatusBanner(
            texto: _erro!,
            tipo: BannerTipo.erro,
            acao: 'Tentar de novo',
            onAcao: _carregar,
          ),
          const SizedBox(height: 16),
        ],
        if (_carregando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_erro == null) ...[
          if (g.membros == 1) ...[
            const InfoNote(
              texto: 'Você é o único membro: o resultado mostra só a sua agenda.', // RN09
            ),
            const SizedBox(height: 12),
          ],
          if (_ocupacoes.isEmpty)
            const EmptyState(
              icone: Icons.event_available_outlined,
              titulo: 'Ninguém ocupado',
              texto: 'Nenhum membro tem compromisso registrado neste dia.',
            )
          else
            _GroupTimeline(
              dia: _dia,
              ocupacoes: _ocupacoes,
              livres: _livres,
              cores: _cores,
              inicioH: inicioH,
              fimH: fimH,
            ),
          const SizedBox(height: 20),
          Text('LIVRES EM COMUM', style: AgendaText.rotulo(t)),
          const SizedBox(height: 8),
          if (_livres.isEmpty)
            const EmptyState(
              icone: Icons.event_busy_outlined,
              titulo: 'Nenhum horário em comum',
              texto: 'Tente outra faixa ou outro dia.',
            )
          else
            for (final i in _livres) ...[
              _LivreTile(
                intervalo: '${_hm(i.inicio)} até ${_hm(i.fim)}',
                duracao: _dur(i.duracao),
              ),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 4),
          const InfoNote(
            texto: 'O resultado depende da agenda preenchida por cada membro.', // RN07
          ),
          const SizedBox(height: 6),
          const InfoNote(
            texto:
                'Só aparecem membros com compromisso neste dia. Os títulos ficam privados: você vê apenas o horário ocupado.',
            icone: Icons.lock_outline,
          ),
        ],
      ],
    );
  }
}

class _SeletorDia extends StatelessWidget {
  const _SeletorDia({
    required this.dia,
    required this.onAnterior,
    required this.onProximo,
    required this.onEscolher,
  });

  final DateTime dia;
  final VoidCallback onAnterior;
  final VoidCallback onProximo;
  final VoidCallback onEscolher;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      radius: 22,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAnterior,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.chevron_left_rounded,
                  size: 26, color: t.textoSuave),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onEscolher,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '${_diasSemana[dia.weekday % 7]}, ${dia.day} de ${_meses[dia.month - 1]}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: t.textoPrincipal,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onProximo,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.chevron_right_rounded,
                  size: 26, color: t.textoSuave),
            ),
          ),
        ],
      ),
    );
  }
}

class _LivreTile extends StatelessWidget {
  const _LivreTile({required this.intervalo, required this.duracao});

  final String intervalo;
  final String duracao;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      radius: 22,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.estadoLivre.withValues(alpha: 0.28),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: t.estadoLivre),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intervalo,
                  style: TextStyle(
                    color: t.textoPrincipal,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(duracao, style: AgendaText.corpoSuave(t)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha do tempo do dia com uma coluna por membro. Cada bloco é só
/// "Ocupado" no horário; a faixa verde ao fundo marca os horários livres
/// em comum calculados pelo servidor.
class _GroupTimeline extends StatelessWidget {
  const _GroupTimeline({
    required this.dia,
    required this.ocupacoes,
    required this.livres,
    required this.cores,
    required this.inicioH,
    required this.fimH,
  });

  final DateTime dia;
  final List<Ocupacao> ocupacoes;
  final List<Intervalo> livres;
  final Map<String, int> cores;
  final int inicioH;
  final int fimH;

  static const double hourHeight = 44;
  static const double gutter = 44;

  /// Horas decorridas desde o início do dia, limitadas a 0–24.
  static double horas(DateTime d, DateTime base) =>
      (d.difference(base).inMinutes / 60.0).clamp(0.0, 24.0);

  static List<(double, double)> _mesclar(List<(double, double)> xs) {
    final v = xs.where((x) => x.$2 > x.$1).toList()
      ..sort((a, b) => a.$1.compareTo(b.$1));
    final out = <(double, double)>[];
    for (final x in v) {
      if (out.isNotEmpty && x.$1 <= out.last.$2) {
        final l = out.removeLast();
        out.add((l.$1, x.$2 > l.$2 ? x.$2 : l.$2));
      } else {
        out.add(x);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final base = DateTime(dia.year, dia.month, dia.day);

    final nomes = <String, String>{};
    for (final o in ocupacoes) {
      nomes[o.usuarioId] = o.nomeMembro;
    }
    final ids = nomes.keys.toList()
      ..sort((a, b) => (cores[a] ?? 0).compareTo(cores[b] ?? 0));

    final porMembro = {
      for (final id in ids)
        id: _mesclar([
          for (final o in ocupacoes)
            if (o.usuarioId == id) (horas(o.inicio, base), horas(o.fim, base)),
        ]),
    };

    final altura = hourHeight * (fimH - inicioH) + 12;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      radius: 28,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final largura = constraints.maxWidth - gutter;
          final colW = largura / ids.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: gutter, bottom: 10),
                child: Row(
                  children: [
                    for (final id in ids)
                      Expanded(
                        child: Column(
                          children: [
                            MemberAvatar(
                              nome: nomes[id]!,
                              cor: t.membro(cores[id] ?? 0),
                              tamanho: 30,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              id == AuthService.uid ? 'Você' : nomes[id]!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: t.textoSuave,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: altura,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var h = inicioH; h <= fimH; h++) ...[
                      Positioned(
                        left: 0,
                        top: (h - inicioH) * hourHeight - 5,
                        width: 40,
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
                        left: gutter,
                        right: 0,
                        top: (h - inicioH) * hourHeight,
                        child: Container(height: 1, color: t.linha),
                      ),
                    ],
                    // Faixas livres em comum, atrás dos blocos ocupados.
                    for (final l in livres)
                      Positioned(
                        left: gutter,
                        width: largura,
                        top: (horas(l.inicio, base) - inicioH) * hourHeight,
                        height: (horas(l.fim, base) - horas(l.inicio, base)) *
                            hourHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: t.estadoLivre.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: t.estadoLivre.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                      ),
                    for (var i = 0; i < ids.length; i++)
                      for (final b in porMembro[ids[i]]!)
                        Positioned(
                          left: gutter + i * colW + 3,
                          width: colW - 6,
                          top: (b.$1 - inicioH) * hourHeight + 1,
                          height: ((b.$2 - b.$1) * hourHeight - 2)
                              .clamp(10.0, double.infinity),
                          child: _Bloco(
                            cor: t.membro(cores[ids[i]] ?? 0),
                            mostrarTexto:
                                (b.$2 - b.$1) * hourHeight >= 26 && colW >= 64,
                          ),
                        ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Bloco extends StatelessWidget {
  const _Bloco({required this.cor, required this.mostrarTexto});

  final Color cor;
  final bool mostrarTexto;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cor.withValues(alpha: 0.7)),
      ),
      alignment: Alignment.center,
      child: mostrarTexto
          ? Text(
              'Ocupado',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: t.textoPrincipal,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}
