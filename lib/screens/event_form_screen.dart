import 'package:flutter/material.dart';

import '../models/modelos.dart';
import '../services/compromisso_service.dart';
import '../services/erros.dart';
import '../theme/agenda_theme.dart';
import '../widgets/agenda_widgets.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _titulo = TextEditingController();
  final _dataTxt = TextEditingController();
  final _iniTxt = TextEditingController();
  final _fimTxt = TextEditingController();

  DateTime _dia = DateTime.now();
  TimeOfDay _ini = const TimeOfDay(hour: 19, minute: 0);
  TimeOfDay _fim = const TimeOfDay(hour: 20, minute: 0);
  bool _lembrete = true;
  bool _salvando = false;
  bool _iniciado = false;
  String? _erro;
  Compromisso? _editando;

  String _d(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  String _h(TimeOfDay h) =>
      '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}';

  bool get _viraNoite =>
      _fim.hour * 60 + _fim.minute < _ini.hour * 60 + _ini.minute;

  // Se o horário de fim é menor que o de início (ex.: 22:00 até 01:00), o
  // compromisso termina no dia seguinte. Fim igual ao início continua inválido.
  DateTime _calcularFim() => DateTime(
        _dia.year,
        _dia.month,
        _dia.day + (_viraNoite ? 1 : 0),
        _fim.hour,
        _fim.minute,
      );

  void _atualizarTextos() {
    _dataTxt.text = _d(_dia);
    _iniTxt.text = _h(_ini);
    _fimTxt.text = _h(_fim);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Compromisso) {
      _editando = arg;
      _titulo.text = arg.titulo;
      _dia = arg.inicio;
      _ini = TimeOfDay.fromDateTime(arg.inicio);
      _fim = TimeOfDay.fromDateTime(arg.fim);
    }
    _atualizarTextos();
  }

  @override
  void dispose() {
    _titulo.dispose();
    _dataTxt.dispose();
    _iniTxt.dispose();
    _fimTxt.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dia,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() { _dia = d; _atualizarTextos(); });
  }

  Future<void> _escolherHora(bool inicio) async {
    final h = await showTimePicker(
      context: context,
      initialTime: inicio ? _ini : _fim,
    );
    if (h == null) return;
    setState(() {
      if (inicio) { _ini = h; } else { _fim = h; }
      _atualizarTextos();
    });
  }

  Future<void> _salvar() async {
    final inicio = DateTime(_dia.year, _dia.month, _dia.day, _ini.hour, _ini.minute);
    final fim = _calcularFim();

    if (_titulo.text.trim().isEmpty) {
      setState(() => _erro = 'Dê um título ao compromisso.');
      return;
    }
    if (!inicio.isBefore(fim)) { // RN01: inicio < fim
      setState(() => _erro = 'O fim precisa ser depois do início.');
      return;
    }

    setState(() { _salvando = true; _erro = null; });
    try {
      if (_editando == null) {
        await CompromissoService.criar(titulo: _titulo.text, inicio: inicio, fim: fim);
      } else {
        await CompromissoService.atualizar(
            id: _editando!.id, titulo: _titulo.text, inicio: inicio, fim: fim);
      }
      if (!mounted) return;
      Navigator.pop(context, true); // true = houve alteração, a Home recarrega
    } catch (e) {
      if (mounted) setState(() => _erro = traduzirErro(e));
    } finally {
      if (mounted) setState(() => _salvando = false);
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
                icone: Icons.close_rounded, onTap: () => Navigator.pop(context)),
            Expanded(
              child: Text(
                _editando == null ? 'Novo compromisso' : 'Editar compromisso',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: t.textoPrincipal, fontSize: 20, fontWeight: FontWeight.w700),
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
              InsetField(label: 'Título', hint: 'Nome do compromisso', controller: _titulo),
              const SizedBox(height: 16),
              InsetField(
                  label: 'Data', controller: _dataTxt, readOnly: true, onTap: _escolherData),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InsetField(
                        label: 'Início', controller: _iniTxt, readOnly: true,
                        onTap: () => _escolherHora(true)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: InsetField(
                        label: 'Fim', controller: _fimTxt, readOnly: true,
                        onTap: () => _escolherHora(false)),
                  ),
                ],
              ),
              if (_viraNoite) ...[
                const SizedBox(height: 10),
                Text(
                  'Termina no dia seguinte (${_d(DateTime(_dia.year, _dia.month, _dia.day + 1))}).',
                  style: AgendaText.corpoSuave(t),
                ),
              ],
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
                        Text('Aviso 30 minutos antes do início',
                            style: AgendaText.corpoSuave(t)),
                      ],
                    ),
                  ),
                  PhysicalToggle(
                    valor: _lembrete,
                    onChanged: (v) => setState(() => _lembrete = v),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_erro != null) ...[
          const SizedBox(height: 16),
          StatusBanner(texto: _erro!, tipo: BannerTipo.erro),
        ],
        const SizedBox(height: 20),
        const InfoNote(
          texto: 'Só você vê o título. Os membros do grupo enxergam apenas o horário ocupado.',
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: _salvando ? 'Salvando...' : 'Salvar compromisso',
          onPressed: _salvando ? null : _salvar,
        ),
        const SizedBox(height: 14),
        GlassButton(label: 'Cancelar', onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}