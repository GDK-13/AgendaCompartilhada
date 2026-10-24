import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/modelos.dart';
import '../services/convite_service.dart';
import '../theme/agenda_theme.dart';
import 'agenda_widgets.dart';

Future<void> mostrarConvite(
  BuildContext context,
  Grupo grupo, {
  String titulo = 'Convidar para o grupo',
}) {
  final t = context.tokens;
  return showGeneralDialog<void>(
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassCard(
                  forte: true,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                  child: _ConviteConteudo(grupo: grupo, titulo: titulo),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _ConviteConteudo extends StatefulWidget {
  const _ConviteConteudo({required this.grupo, required this.titulo});

  final Grupo grupo;
  final String titulo;

  @override
  State<_ConviteConteudo> createState() => _ConviteConteudoState();
}

class _ConviteConteudoState extends State<_ConviteConteudo> {
  String? _copiado; // 'codigo' | 'link'

  Future<void> _copiar(String chave, String texto) async {
    await Clipboard.setData(ClipboardData(text: texto));
    if (!mounted) return;
    setState(() => _copiado = chave);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _copiado == chave) setState(() => _copiado = null);
    });
  }

  Future<void> _compartilhar() async {
    await SharePlus.instance.share(
      ShareParams(
        text: ConviteService.mensagem(widget.grupo),
        subject: 'Convite para ${widget.grupo.nome}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final codigo = widget.grupo.codigo;
    final link = ConviteService.gerarLink(codigo);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.titulo,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: t.textoPrincipal,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.grupo.nome,
          textAlign: TextAlign.center,
          style: AgendaText.corpoSuave(t),
        ),
        const SizedBox(height: 20),
        Text('CÓDIGO', style: AgendaText.rotulo(t)),
        const SizedBox(height: 4),
        SelectableText(
          codigo,
          style: TextStyle(
            color: t.textoPrincipal,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Text('LINK', style: AgendaText.rotulo(t)),
        const SizedBox(height: 4),
        SelectableText(link, style: AgendaText.corpoSuave(t)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: GlassButton(
                label: _copiado == 'codigo' ? 'Copiado!' : 'Copiar código',
                onPressed: () => _copiar('codigo', codigo),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassButton(
                label: _copiado == 'link' ? 'Copiado!' : 'Copiar link',
                onPressed: () => _copiar('link', link),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Compartilhar convite',
          icone: Icons.ios_share_rounded,
          onPressed: _compartilhar,
        ),
        const SizedBox(height: 12),
        GlassButton(
          label: 'Fechar',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}