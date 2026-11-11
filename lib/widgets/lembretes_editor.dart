import 'package:flutter/material.dart';

import '../services/notificacao_service.dart';
import '../theme/agenda_theme.dart';
import 'agenda_widgets.dart';

/// Editor de lembretes no estilo Google Agenda: lista de avisos (cada um com
/// sua antecedência), botão "Adicionar lembrete" e opção "Personalizado...".
///
/// Sem estado próprio: recebe a lista em [minutos] e devolve a nova lista em
/// [onChanged] (já normalizada: sem repetidos, do mais distante ao mais próximo).
class LembretesEditor extends StatelessWidget {
  const LembretesEditor({
    super.key,
    required this.minutos,
    required this.onChanged,
  });

  final List<int> minutos;
  final ValueChanged<List<int>> onChanged;

  static const _atalhos = [0, 5, 10, 15, 30, 60, 120, 1440, 2880, 10080];

  void _emitir(Iterable<int> l) => onChanged(NotificacaoService.normalizar(l));

  Future<void> _escolher(BuildContext context, {int? substituir}) async {
    final m = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _Opcoes(inicial: substituir),
    );
    if (m == null || !context.mounted) return;
    final base = [...minutos]..remove(substituir);
    if (base.contains(m)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esse lembrete já existe.')),
      );
      return;
    }
    _emitir([...base, m]);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final cheio = minutos.length >= NotificacaoService.maxPorCompromisso;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final m in minutos)
          InkWell(
            borderRadius: BorderRadius.circular(AgendaDims.raioCampo),
            onTap: () => _escolher(context, substituir: m),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 20, color: t.textoSuave),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(NotificacaoService.rotulo(m),
                        style: AgendaText.corpo(t)),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _emitir(minutos.where((x) => x != m)),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.close_rounded,
                          size: 20, color: t.textoSuave),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (minutos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text('Nenhum lembrete', style: AgendaText.corpoSuave(t)),
          ),
        if (!cheio)
          InkWell(
            borderRadius: BorderRadius.circular(AgendaDims.raioCampo),
            onTap: () => _escolher(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.add_rounded, size: 20, color: t.acentoBase),
                  const SizedBox(width: 12),
                  Text('Adicionar lembrete', style: AgendaText.link(t)),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Limite de ${NotificacaoService.maxPorCompromisso} lembretes por compromisso.',
              style: AgendaText.corpoSuave(t),
            ),
          ),
      ],
    );
  }
}

/// Folha com os atalhos (na hora, 5 min, 1 hora...) e "Personalizado...".
class _Opcoes extends StatelessWidget {
  const _Opcoes({this.inicial});

  final int? inicial;

  Future<void> _personalizado(BuildContext context) async {
    final m = await showDialog<int>(
      context: context,
      builder: (_) => _Personalizado(inicial: inicial),
    );
    if (m != null && context.mounted) Navigator.pop(context, m);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GlassCard(
          forte: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final m in LembretesEditor._atalhos)
                  ListTile(
                    dense: true,
                    title: Text(NotificacaoService.rotulo(m),
                        style: AgendaText.corpo(t)),
                    trailing: m == inicial
                        ? Icon(Icons.check_rounded, color: t.acentoBase)
                        : null,
                    onTap: () => Navigator.pop(context, m),
                  ),
                Divider(color: t.linha),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.tune_rounded, color: t.acentoBase),
                  title: Text('Personalizado...', style: AgendaText.link(t)),
                  onTap: () => _personalizado(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _Unidade {
  min('minutos', 1),
  horas('horas', 60),
  dias('dias', 1440),
  semanas('semanas', 10080);

  const _Unidade(this.nome, this.minutos);
  final String nome;
  final int minutos;
}

/// Diálogo "quantidade + unidade" (minutos, horas, dias ou semanas antes).
class _Personalizado extends StatefulWidget {
  const _Personalizado({this.inicial});

  final int? inicial;

  @override
  State<_Personalizado> createState() => _PersonalizadoState();
}

class _PersonalizadoState extends State<_Personalizado> {
  final _qtd = TextEditingController();
  _Unidade _un = _Unidade.min;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final m = widget.inicial;
    if (m != null && m > 0) {
      // maior unidade que divide exatamente o valor
      _un = _Unidade.values.reversed.firstWhere(
        (u) => m % u.minutos == 0,
        orElse: () => _Unidade.min,
      );
      _qtd.text = '${m ~/ _un.minutos}';
    } else {
      _qtd.text = '10';
    }
  }

  @override
  void dispose() {
    _qtd.dispose();
    super.dispose();
  }

  void _ok() {
    final n = int.tryParse(_qtd.text.trim());
    if (n == null || n <= 0) {
      setState(() => _erro = 'Informe um número maior que zero.');
      return;
    }
    final total = n * _un.minutos;
    if (total > NotificacaoService.maxMinutos) {
      setState(() => _erro = 'O máximo é 4 semanas antes.');
      return;
    }
    Navigator.pop(context, total);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: GlassCard(
        forte: true,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Lembrete personalizado',
                style: TextStyle(
                    color: t.textoPrincipal,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            InsetField(
              label: 'Quanto tempo antes',
              controller: _qtd,
              keyboardType: TextInputType.number,
              erro: _erro,
              onChanged: (_) {
                if (_erro != null) setState(() => _erro = null);
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final u in _Unidade.values)
                  ChoiceChip(
                    label: Text(u.nome),
                    selected: _un == u,
                    selectedColor: t.acentoSuave,
                    onSelected: (_) => setState(() {
                      _un = u;
                      _erro = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: 'Cancelar',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: PrimaryButton(label: 'OK', onPressed: _ok),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
