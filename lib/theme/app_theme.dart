// app_theme.dart — tokens e widgets-base do app Agenda Compartilhada.
// As chaves das paletas são IGUAIS aos nomes das variáveis do Figma
// (coleções "Tema · …"), então o mapeamento é 1:1: p['acento/base'].
import 'dart:ui';
import 'package:flutter/material.dart';

Color _c(int rgb, [double a = 1]) =>
    Color.fromRGBO((rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255, a);

const _keys = [
  'fundo/base', 'fundo/mancha1', 'fundo/mancha2', 'fundo/mancha3', 'fundo/mancha4',
  'texto/principal', 'texto/suave',
  'acento/base', 'acento/sobre', 'acento/sombra', 'acento/brilho', 'acento/base-escura',
  'membro/a', 'membro/b', 'membro/c', 'evento/c', 'estado/livre', 'estado/erro',
  'vidro/normal', 'vidro/suave', 'vidro/forte', 'vidro/borda',
  'relevo/brilho', 'relevo/brilho-suave', 'relevo/sombra-baixa', 'relevo/sombra',
  'relevo/sombra-curta', 'relevo/sombra-forte',
  'campo/fundo', 'campo/borda', 'campo/lip', 'campo/sombra',
  'superficie/papel', 'superficie/knob', 'linha', 'scrim',
];

class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette(this.nome, this.escuro, this._t);
  final String nome;
  final bool escuro;
  final Map<String, Color> _t;

  Color operator [](String k) => _t[k] ?? (throw ArgumentError('token $k'));

  factory AppPalette._mk(String nome, bool escuro, List<int> rgb, List<double> a) {
    final t = {for (var i = 0; i < _keys.length; i++) _keys[i]: _c(rgb[i], a[i])};
    Color base(String k, double al) => t[k]!.withValues(alpha: al);
    // tokens derivados (existem no Figma com os mesmos nomes)
    t['texto/fraco'] = base('texto/principal', .5);
    t['acento/suave'] = base('acento/base', .22);
    t['estado/erro-suave'] = base('estado/erro', .22);
    t['estado/livre-suave'] = base('estado/livre', .25);
    t['evento/a-suave'] = base('membro/a', .5);
    t['evento/b-suave'] = base('membro/b', .5);
    t['evento/c-suave'] = base('evento/c', .5);
    t['membro/c-suave'] = base('membro/c', .5);
    return AppPalette(nome, escuro, t);
  }

  static const _w = 0xFFFFFF;

  static final aconchegante = AppPalette._mk('Aconchegante', false, [
    0xF4EADF, 0xE8A07F, 0xA9C1A3, 0xEFC66F, 0xDDA0A0, 0x4A3426, 0x8B735F,
    0xC8694A, 0xFFFFFF, 0x7A3A22, _w, 0x5A2410, 0xD9825F, 0x8FAA8B, 0x7C9BB3, 0xE3B04B, 0x8FAA8B, 0xC0483A,
    _w, _w, _w, _w, _w, _w, 0x8A6446, 0x5A3A24, 0x5A3A24, 0x5A3A24,
    0xE9D9C6, 0xD6C2AA, _w, 0x5A3A24, 0xFFF8EE, 0xFFFDF8, 0x4A3426, 0x2A1A10,
  ], [
    1, .6, .6, .55, .45, 1, 1,
    1, 1, .38, .45, .3, 1, 1, 1, 1, 1, 1,
    .5, .42, .6, .65, .9, .5, .12, .16, .10, .3,
    .7, .6, .85, .22, 1, 1, .12, .35,
  ]);

  static final azulClaro = AppPalette._mk('Azul claro', false, [
    0xEEF3FA, 0xB8CDEA, 0xCCDDF2, 0xA9C2E6, 0xD3DEF0, 0x25344F, 0x66779A,
    0x4F7FC9, 0xFFFFFF, 0x12306B, _w, 0x0B1F4A, 0x5C8AD3, 0x7FB0D8, 0x8EA2D6, 0x9DB4DF, 0x7FB6C9, 0xC94F4F,
    _w, _w, _w, _w, _w, _w, 0x4A648F, 0x243759, 0x243759, 0x243759,
    0xDDE6F5, 0xC3D2EA, _w, 0x243759, 0xF5F9FF, 0xFFFFFF, 0x25344F, 0x14213D,
  ], [
    1, .7, .7, .5, .6, 1, 1,
    1, 1, .35, .45, .3, 1, 1, 1, 1, 1, 1,
    .55, .45, .65, .7, .9, .5, .12, .16, .10, .3,
    .7, .6, .85, .2, 1, 1, .12, .35,
  ]);

  static final azulEscuro = AppPalette._mk('Azul escuro', true, [
    0x121A2B, 0x2E4A80, 0x26456E, 0x355C9A, 0x1F3A66, 0xE6ECF7, 0x9AA8C2,
    0x6F9BE0, 0x0E1626, 0x000000, _w, 0x000000, 0x7FA6E6, 0x6FB5CF, 0x9AA9E0, 0x8DA0D8, 0x74B8B0, 0xE07A7A,
    _w, _w, _w, _w, _w, _w, 0x000000, 0x000000, 0x000000, 0x000000,
    0x0B1322, 0x2A3A5C, _w, 0x000000, 0xE6ECF7, 0xE6ECF7, 0xE6ECF7, 0x000000,
  ], [
    1, .35, .3, .25, .3, 1, 1,
    1, 1, .5, .3, .35, 1, 1, 1, 1, 1, 1,
    .07, .05, .1, .16, .18, .12, .3, .4, .3, .5,
    .6, .6, .08, .5, 1, 1, .12, .55,
  ]);

  static final multicoloClaro = AppPalette._mk('Multicolor claro', false, [
    0xF6F5FC, 0xB9A3F0, 0x9CC8F5, 0xA8E2CB, 0xD9CCF7, 0x2B2850, 0x6D6A92,
    0x7B5CD6, 0xFFFFFF, 0x3A2490, _w, 0x25165F, 0x8F6FE6, 0x4FBF9A, 0x47B3D6, 0x5B9BE8, 0x4FBF9A, 0xD0506A,
    _w, _w, _w, _w, _w, _w, 0x5A4F9A, 0x2B2850, 0x2B2850, 0x2B2850,
    0xE7E4F5, 0xCFC9EA, _w, 0x2B2850, 0xF8F6FF, 0xFFFFFF, 0x2B2850, 0x14102E,
  ], [
    1, .6, .6, .55, .5, 1, 1,
    1, 1, .35, .45, .3, 1, 1, 1, 1, 1, 1,
    .55, .45, .65, .7, .9, .5, .12, .16, .10, .3,
    .7, .6, .85, .22, 1, 1, .12, .35,
  ]);

  static final roxoRosaEscuro = AppPalette._mk('Roxo e rosa escuro', true, [
    0x1A1424, 0x6B4A9A, 0x4A3A80, 0x8A4A7A, 0x7A4A90, 0xF1E8F7, 0xB3A3C8,
    0xC77DA8, 0x2A1230, 0x000000, _w, 0x000000, 0xD58BB5, 0xA590DE, 0xC0A3E2, 0xBFA2E6, 0x9AA0E0, 0xE88AA0,
    _w, _w, _w, _w, _w, _w, 0x000000, 0x000000, 0x000000, 0x000000,
    0x120B1C, 0x3A2A52, _w, 0x000000, 0xF1E8F7, 0xF1E8F7, 0xF1E8F7, 0x000000,
  ], [
    1, .35, .3, .3, .28, 1, 1,
    1, 1, .5, .3, .35, 1, 1, 1, 1, 1, 1,
    .08, .06, .11, .16, .18, .12, .3, .4, .3, .5,
    .6, .6, .08, .5, 1, 1, .12, .55,
  ]);

  static final todas = [aconchegante, azulClaro, azulEscuro, multicoloClaro, roxoRosaEscuro];

  static AppPalette of(BuildContext c) => Theme.of(c).extension<AppPalette>()!;

  @override
  AppPalette copyWith() => this;
  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) => t < .5 ? this : (other as AppPalette);
}

class AppTheme {
  static ThemeData build(AppPalette p) {
    final b = p.escuro ? Brightness.dark : Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: p['fundo/base'],
      colorScheme: ColorScheme.fromSeed(seedColor: p['acento/base'], brightness: b).copyWith(
        primary: p['acento/base'],
        onPrimary: p['acento/sobre'],
        surface: p['fundo/base'],
        onSurface: p['texto/principal'],
        error: p['estado/erro'],
      ),
      extensions: [p],
    );
  }
}

/// Estilos de texto: Figma "Texto/<tamanho> <peso>" -> AppText.t(<tamanho>, <peso>)
class AppText {
  static TextStyle t(BuildContext c, double size, FontWeight w, {bool suave = false}) =>
      TextStyle(fontSize: size, fontWeight: w, color: AppPalette.of(c)[suave ? 'texto/suave' : 'texto/principal']);
  // Medium=w500, Semi Bold=w600, Bold=w700, Regular=w400
}

/// Sombra interna (o Flutter não tem BoxShadow inset).
class InnerShadowPainter extends CustomPainter {
  InnerShadowPainter(this.radius, this.shadows);
  final BorderRadius radius;
  final List<BoxShadow> shadows;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = radius.toRRect(rect);
    canvas.save();
    canvas.clipRRect(rrect);
    for (final s in shadows) {
      final paint = Paint()
        ..color = s.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blurSigma);
      final outer = Path()..addRect(rect.inflate(60));
      final hole = Path()..addRRect(rrect.shift(s.offset));
      canvas.drawPath(Path.combine(PathOperation.difference, outer, hole), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant InnerShadowPainter old) => true;
}

enum GlassLevel { suave, normal, forte }

/// Figma: componente "GlassCard"
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.radius = 24, this.padding, this.nivel = GlassLevel.normal});
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final GlassLevel nivel;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final br = BorderRadius.circular(radius);
    final fill = p[switch (nivel) {
      GlassLevel.suave => 'vidro/suave',
      GlassLevel.normal => 'vidro/normal',
      GlassLevel.forte => 'vidro/forte',
    }];
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: br, boxShadow: [
        BoxShadow(color: p['relevo/sombra'], offset: const Offset(0, 10), blurRadius: 28),
        BoxShadow(color: p['relevo/sombra-curta'], offset: const Offset(0, 2), blurRadius: 6),
      ]),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: CustomPaint(
            foregroundPainter: InnerShadowPainter(br, [
              BoxShadow(color: p['relevo/brilho'], offset: const Offset(0, 1.5), blurRadius: 0),
              BoxShadow(color: p['relevo/sombra-baixa'], offset: const Offset(0, -2), blurRadius: 3),
            ]),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(color: fill, borderRadius: br, border: Border.all(color: p['vidro/borda'])),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma: componente "InsetField" (campo "afundado")
class InsetBox extends StatelessWidget {
  const InsetBox({super.key, required this.child, this.radius = 16, this.erro = false, this.padding = const EdgeInsets.symmetric(horizontal: 18)});
  final Widget child;
  final double radius;
  final bool erro;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final br = BorderRadius.circular(radius);
    return CustomPaint(
      foregroundPainter: InnerShadowPainter(br, [
        BoxShadow(color: p['campo/sombra'], offset: const Offset(0, 3), blurRadius: 5),
        BoxShadow(color: p['campo/lip'], offset: const Offset(0, -1), blurRadius: 0),
      ]),
      child: Container(
        height: 48,
        padding: padding,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: p['campo/fundo'],
          borderRadius: br,
          border: Border.all(color: erro ? p['estado/erro'] : p['campo/borda'], width: erro ? 1.5 : 1),
        ),
        child: child,
      ),
    );
  }
}

/// Figma: componente "PrimaryButton"
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.radius = 18, this.perigo = false});
  final String label;
  final VoidCallback? onPressed;
  final double radius;
  final bool perigo;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final br = BorderRadius.circular(radius);
    return GestureDetector(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: br, boxShadow: [
          BoxShadow(color: p['acento/sombra'], offset: const Offset(0, 8), blurRadius: 16),
          BoxShadow(color: p['acento/sombra'], offset: const Offset(0, 2), blurRadius: 3),
        ]),
        child: CustomPaint(
          foregroundPainter: InnerShadowPainter(br, [
            BoxShadow(color: p['acento/brilho'], offset: const Offset(0, 2), blurRadius: 0),
            BoxShadow(color: p['acento/base-escura'], offset: const Offset(0, -3), blurRadius: 4),
          ]),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: perigo ? p['estado/erro'] : p['acento/base'], borderRadius: br),
            child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: p['acento/sobre'])),
          ),
        ),
      ),
    );
  }
}

/// Fundo com as "manchas" desfocadas (as 4 variáveis fundo/mancha1..4).
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    Widget blob(double d, Color c) => ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
          child: Container(width: d, height: d, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        );
    return Stack(children: [
      Positioned.fill(child: ColoredBox(color: p['fundo/base'])),
      Positioned(left: -70, top: -50, child: blob(280, p['fundo/mancha1'])),
      Positioned(right: -90, top: 260, child: blob(260, p['fundo/mancha2'])),
      Positioned(left: -80, bottom: 80, child: blob(280, p['fundo/mancha3'])),
      Positioned(right: -60, bottom: -40, child: blob(220, p['fundo/mancha4'])),
      Positioned.fill(child: child),
    ]);
  }
}

// Uso:
//   MaterialApp(theme: AppTheme.build(AppPalette.aconchegante), ...)
//   Para trocar o tema em tempo de execução, guarde o AppPalette escolhido num
//   ValueNotifier/Provider e reconstrua o MaterialApp com AppTheme.build(escolhida).
