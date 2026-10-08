import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/agenda_theme.dart';
import '../theme/app_theme.dart' as figma;

/// Estilos de texto baseados nos tokens do tema ativo.
class AgendaText {
  AgendaText._();

  static TextStyle titulo(AgendaTokens t) => TextStyle(
        color: t.textoPrincipal,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.15,
      );

  static TextStyle subtitulo(AgendaTokens t) =>
      TextStyle(color: t.textoSuave, fontSize: 14, height: 1.35);

  static TextStyle corpo(AgendaTokens t) => TextStyle(
        color: t.textoPrincipal,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      );

  static TextStyle corpoSuave(AgendaTokens t) =>
      TextStyle(color: t.textoSuave, fontSize: 13, height: 1.35);

  static TextStyle rotulo(AgendaTokens t) => TextStyle(
        color: t.textoSuave,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );

  static TextStyle link(AgendaTokens t) => TextStyle(
        color: t.acentoBase,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );
}

/// Fundo creme/colorido com as 4 manchas desfocadas.
class AgendaBackground extends StatelessWidget {
  const AgendaBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ClipRect(
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: t.fundoBase)),
          _Mancha(left: -70, top: -50, size: 280, color: t.fundoMancha1),
          _Mancha(left: 220, top: 260, size: 260, color: t.fundoMancha2),
          _Mancha(left: -80, top: 540, size: 280, color: t.fundoMancha3),
          _Mancha(left: 230, top: 640, size: 220, color: t.fundoMancha4),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Mancha extends StatelessWidget {
  const _Mancha({
    required this.left,
    required this.top,
    required this.size,
    required this.color,
  });

  final double left;
  final double top;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: AgendaDims.desfoqueMancha,
          sigmaY: AgendaDims.desfoqueMancha,
          tileMode: TileMode.decal,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

/// Painel de acrílico: vidro translúcido com desfoque de fundo, borda e sombra.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = AgendaDims.raioCartao,
    this.forte = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool forte;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final borda = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: borda, boxShadow: t.sombraCartao),
      child: ClipRRect(
        borderRadius: borda,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AgendaDims.desfoqueVidro,
            sigmaY: AgendaDims.desfoqueVidro,
          ),
          child: CustomPaint(
            foregroundPainter: figma.InnerShadowPainter(
              borda,
              [
                BoxShadow(
                  color: t.relevoBrilho,
                  offset: const Offset(0, 1.5),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: t.relevoSombraBaixa,
                  offset: const Offset(0, -2),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: forte ? t.vidroForte : t.vidroNormal,
                borderRadius: borda,
                border: Border.all(color: t.vidroBorda, width: 1),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Campo "afundado" com rótulo e mensagem de erro opcional.
class InsetField extends StatefulWidget {
  const InsetField({
    super.key,
    required this.label,
    this.valor = '',
    this.hint,
    this.obscure = false,
    this.trailing,
    this.erro,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final String valor;
  final String? hint;
  final bool obscure;
  final Widget? trailing;
  final String? erro;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  State<InsetField> createState() => _InsetFieldState();
}

class _InsetFieldState extends State<InsetField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.valor);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final temErro = widget.erro != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(widget.label, style: AgendaText.rotulo(t)),
        ),
        CustomPaint(
          foregroundPainter: figma.InnerShadowPainter(
            BorderRadius.circular(AgendaDims.raioCampo),
            [
              BoxShadow(
                color: t.campoSombra,
                offset: const Offset(0, 3),
                blurRadius: 5,
              ),
              BoxShadow(
                color: t.campoLip,
                offset: const Offset(0, -1),
                blurRadius: 0,
              ),
            ],
          ),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: t.campoFundo,
              borderRadius: BorderRadius.circular(AgendaDims.raioCampo),
              border: Border.all(
                color: temErro ? t.estadoErro : t.campoBorda,
                width: temErro ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    obscureText: widget.obscure,
                    keyboardType: widget.keyboardType,
                    onChanged: widget.onChanged,
                    cursorColor: t.acentoBase,
                    style: AgendaText.corpo(t),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: widget.hint,
                      hintStyle: TextStyle(color: t.textoFraco, fontSize: 15),
                    ),
                  ),
                ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
          ),
        ),
        if (temErro)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 14, color: t.estadoErro),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    widget.erro!,
                    style: TextStyle(
                      color: t.estadoErro,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Botão primário com relevo. `perigo` usa a cor de erro (excluir, sair).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.perigo = false,
    this.icone,
    this.altura = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool perigo;
  final IconData? icone;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final cor = perigo ? t.estadoErro : t.acentoBase;
    final sobre = perigo ? Colors.white : t.acentoSobre;
    final borda = BorderRadius.circular(AgendaDims.raioBotao);
    return Container(
      height: altura,
      decoration: BoxDecoration(
        color: cor,
        borderRadius: borda,
        boxShadow: t.sombraBotao,
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: CustomPaint(
        foregroundPainter: figma.InnerShadowPainter(
          borda,
          [
            BoxShadow(
              color: t.acentoBrilho,
              offset: const Offset(0, 2),
              blurRadius: 0,
            ),
            BoxShadow(
              color: t.acentoBaseEscura,
              offset: const Offset(0, -3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borda,
            onTap: onPressed,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icone != null) ...[
                    Icon(icone, size: 18, color: sobre),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: sobre,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão secundário de vidro. `cor` muda a cor do texto (ex.: estadoErro).
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.cor,
    this.altura = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? cor;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final borda = BorderRadius.circular(AgendaDims.raioBotao);
    return Container(
      height: altura,
      decoration: BoxDecoration(
        color: t.vidroNormal,
        borderRadius: borda,
        border: Border.all(color: t.vidroBorda),
        boxShadow: [
          BoxShadow(
            color: t.sombraCor.withValues(alpha: t.escuro ? 0.30 : 0.10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borda,
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: cor ?? t.textoSuave,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Toggle com botão físico (knob) em relevo.
class PhysicalToggle extends StatelessWidget {
  const PhysicalToggle({super.key, required this.valor, this.onChanged});

  final bool valor;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 60,
        height: 34,
        padding: const EdgeInsets.all(3),
        alignment: valor ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: valor ? t.estadoLivre : t.campoFundo,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: t.campoBorda),
        ),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: t.superficieKnob,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: t.sombraCor.withValues(alpha: t.escuro ? 0.5 : 0.28),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar circular com a cor fixa do membro.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.nome,
    required this.cor,
    this.tamanho = 40,
  });

  final String nome;
  final Color cor;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final inicial = nome.isEmpty ? '?' : nome.characters.first.toUpperCase();
    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Text(
        inicial,
        style: TextStyle(
          color: Colors.white,
          fontSize: tamanho * 0.42,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Botão redondo de vidro (voltar, fechar).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icone, this.onTap});

  final IconData icone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: t.vidroForte,
          shape: BoxShape.circle,
          border: Border.all(color: t.vidroBorda),
        ),
        child: Icon(icone, size: 22, color: t.textoPrincipal),
      ),
    );
  }
}

/// Logo provisório (o app ainda não tem nome/identidade definidos).
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.tamanho = 96});

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: t.vidroForte,
        shape: BoxShape.circle,
        border: Border.all(color: t.vidroBorda),
        boxShadow: t.sombraCartao,
      ),
      child: Icon(Icons.event_available_rounded,
          size: tamanho * 0.46, color: t.acentoBase),
    );
  }
}

/// Cabeçalho de tela: botão à esquerda opcional, título, subtítulo e ação à direita.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.leading,
    this.trailing,
  });

  final String titulo;
  final String? subtitulo;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(height: 16),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(titulo, style: AgendaText.titulo(t))),
            if (trailing != null) trailing!,
          ],
        ),
        if (subtitulo != null) ...[
          const SizedBox(height: 6),
          Text(subtitulo!, style: AgendaText.subtitulo(t)),
        ],
      ],
    );
  }
}

/// Estrutura padrão de tela: fundo, área segura, rolagem e tab bar opcional.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.children,
    this.header,
    this.tabIndex,
    this.onTab,
    this.floatingAction,
  });

  final List<Widget> children;
  final Widget? header;
  final int? tabIndex;
  final ValueChanged<int>? onTab;
  final Widget? floatingAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.fundoBase,
      body: AgendaBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      24, 16, 24, tabIndex == null ? 24 : 108),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (header != null) header!,
                      ...children,
                    ],
                  ),
                ),
              ),
              if (floatingAction != null)
                Positioned(
                  right: 34,
                  bottom: tabIndex == null ? 24 : 92,
                  child: floatingAction!,
                ),
              if (tabIndex != null)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 12,
                  child: GlassTabBar(selected: tabIndex!, onTap: onTab),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra de abas flutuante: Agenda, Grupos, Livres, Perfil.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({super.key, required this.selected, this.onTap});

  final int selected;
  final ValueChanged<int>? onTap;

  static const _itens = <_TabItem>[
    _TabItem(Icons.calendar_today_outlined, 'Agenda'),
    _TabItem(Icons.group_outlined, 'Grupos'),
    _TabItem(Icons.schedule, 'Livres'),
    _TabItem(Icons.person_outline, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GlassCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          for (var i = 0; i < _itens.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap == null ? null : () => onTap!(i),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: i == selected ? t.acentoSuave : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _itens[i].icone,
                        size: 20,
                        color: i == selected ? t.acentoBase : t.textoSuave,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _itens[i].nome,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: i == selected ? t.acentoBase : t.textoSuave,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabItem {
  const _TabItem(this.icone, this.nome);
  final IconData icone;
  final String nome;
}

enum BannerTipo { erro, info, ok }

/// Faixa de aviso (erro de rede, código inválido, informações).
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.texto,
    this.tipo = BannerTipo.info,
    this.icone,
    this.acao,
    this.onAcao,
  });

  final String texto;
  final BannerTipo tipo;
  final IconData? icone;
  final String? acao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final Color cor;
    final IconData iconePadrao;
    switch (tipo) {
      case BannerTipo.erro:
        cor = t.estadoErro;
        iconePadrao = Icons.error_outline;
      case BannerTipo.ok:
        cor = t.estadoLivre;
        iconePadrao = Icons.check_circle_outline;
      case BannerTipo.info:
        cor = t.acentoBase;
        iconePadrao = Icons.info_outline;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AgendaDims.raioCampo + 2),
        border: Border.all(color: cor.withValues(alpha: 0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone ?? iconePadrao, size: 20, color: cor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(texto,
                    style: TextStyle(
                        color: t.textoPrincipal, fontSize: 13, height: 1.35)),
                if (acao != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onAcao,
                    child: Text(
                      acao!,
                      style: TextStyle(
                        color: cor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão de informação com ícone "i" (avisos de privacidade, RN07, RN12).
class InfoNote extends StatelessWidget {
  const InfoNote({super.key, required this.texto, this.icone = Icons.info_outline});

  final String texto;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration:
                BoxDecoration(color: t.acentoSuave, shape: BoxShape.circle),
            child: Icon(icone, size: 16, color: t.acentoBase),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: AgendaText.corpoSuave(t))),
        ],
      ),
    );
  }
}

/// Estado vazio: ícone em vidro, título, texto e ações.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icone,
    required this.titulo,
    required this.texto,
    this.acoes = const [],
  });

  final IconData icone;
  final String titulo;
  final String texto;
  final List<Widget> acoes;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration:
                BoxDecoration(color: t.acentoSuave, shape: BoxShape.circle),
            child: Icon(icone, size: 34, color: t.acentoBase),
          ),
          const SizedBox(height: 18),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: t.textoPrincipal,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(texto,
              textAlign: TextAlign.center, style: AgendaText.corpoSuave(t)),
          if (acoes.isNotEmpty) ...[
            const SizedBox(height: 24),
            for (var i = 0; i < acoes.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              acoes[i],
            ],
          ],
        ],
      ),
    );
  }
}

/// Sugestão de horário livre em comum.
class FreeSlotCard extends StatelessWidget {
  const FreeSlotCard({
    super.key,
    required this.intervalo,
    required this.duracao,
    this.onCombinar,
  });

  final String intervalo;
  final String duracao;
  final VoidCallback? onCombinar;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 24,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.estadoLivre.withValues(alpha: 0.28),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: t.estadoLivre),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intervalo,
                  style: TextStyle(
                    color: t.textoPrincipal,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(duracao, style: AgendaText.corpoSuave(t)),
              ],
            ),
          ),
          SizedBox(
            width: 104,
            child: PrimaryButton(
                label: 'Combinar', altura: 40, onPressed: onCombinar),
          ),
        ],
      ),
    );
  }
}
