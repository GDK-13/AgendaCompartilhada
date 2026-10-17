import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/erros.dart';
import '../services/grupo_service.dart';
import '../widgets/agenda_widgets.dart';

class GroupFormScreen extends StatefulWidget {
  const GroupFormScreen({super.key});

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  final _nome = TextEditingController();
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    if (_salvando) return;
    if (_nome.text.trim().isEmpty) {
      setState(() => _erro = 'Dê um nome ao grupo.');
      return;
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      final g = await GrupoService.criar(_nome.text);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Grupo criado!'),
          content: SelectableText('Código para convidar:\n\n${g.codigo}'),
          actions: [
            TextButton(
              onPressed: () => Clipboard.setData(ClipboardData(text: g.codigo)),
              child: const Text('Copiar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Erro ao criar grupo: $e');
      if (mounted) setState(() => _erro = traduzirErro(e));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      header: ScreenHeader(
        titulo: 'Criar grupo',
        leading: RoundIconButton(
          icone: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context),
        ),
      ),
      children: [
        const SizedBox(height: 20),
        GlassCard(
          child: InsetField(
            label: 'Nome do grupo',
            hint: 'Exemplo: Trabalho PPDM',
            controller: _nome,
          ),
        ),
        if (_erro != null) ...[
          const SizedBox(height: 16),
          StatusBanner(texto: _erro!, tipo: BannerTipo.erro),
        ],
        const SizedBox(height: 20),
        PrimaryButton(
          label: _salvando ? 'Criando...' : 'Criar grupo',
          icone: Icons.group_add_outlined,
          onPressed: _salvando ? null : _criar,
        ),
      ],
    );
  }
}