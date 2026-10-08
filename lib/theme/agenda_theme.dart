import 'package:flutter/material.dart';

import 'app_theme.dart' as figma;

/// Medidas estruturais reutilizadas pelas telas do aplicativo.
class AgendaDims {
  AgendaDims._();

  static const double telaLargura = 390;
  static const double telaAltura = 844;

  static const double raioCampo = 16;
  static const double raioBotao = 20;
  static const double raioCartao = 28;
  static const double raioPill = 32;

  static const double espaco4 = 4;
  static const double espaco8 = 8;
  static const double espaco12 = 12;
  static const double espaco16 = 16;
  static const double espaco24 = 24;

  static const double desfoqueVidro = 24;
  static const double desfoqueMancha = 35;
  static const String fonte = 'Inter';
}

/// Adaptador dos tokens exportados do Figma para a API já usada pelo projeto.
///
/// A fonte de verdade das cinco paletas continua sendo [figma.AppPalette], em
/// `app_theme.dart`. Assim, as telas antigas e novas usam exatamente as mesmas
/// cores sem precisar reescrever o restante do aplicativo.
@immutable
class AgendaTokens extends ThemeExtension<AgendaTokens> {
  AgendaTokens.fromPalette({required this.id, required figma.AppPalette palette})
      : nome = palette.nome,
        brightness = palette.escuro ? Brightness.dark : Brightness.light,
        fundoBase = palette['fundo/base'],
        fundoMancha1 = palette['fundo/mancha1'],
        fundoMancha2 = palette['fundo/mancha2'],
        fundoMancha3 = palette['fundo/mancha3'],
        fundoMancha4 = palette['fundo/mancha4'],
        vidroSuave = palette['vidro/suave'],
        vidroNormal = palette['vidro/normal'],
        vidroForte = palette['vidro/forte'],
        vidroBorda = palette['vidro/borda'],
        campoFundo = palette['campo/fundo'],
        campoBorda = palette['campo/borda'],
        campoLip = palette['campo/lip'],
        campoSombra = palette['campo/sombra'],
        textoPrincipal = palette['texto/principal'],
        textoSuave = palette['texto/suave'],
        textoFraco = palette['texto/fraco'],
        acentoBase = palette['acento/base'],
        acentoSuave = palette['acento/suave'],
        acentoSobre = palette['acento/sobre'],
        acentoSombra = palette['acento/sombra'],
        acentoBrilho = palette['acento/brilho'],
        acentoBaseEscura = palette['acento/base-escura'],
        estadoErro = palette['estado/erro'],
        estadoErroSuave = palette['estado/erro-suave'],
        estadoLivre = palette['estado/livre'],
        estadoLivreSuave = palette['estado/livre-suave'],
        membroA = palette['membro/a'],
        membroB = palette['membro/b'],
        membroC = palette['membro/c'],
        membroCSuave = palette['membro/c-suave'],
        eventoASuave = palette['evento/a-suave'],
        eventoBSuave = palette['evento/b-suave'],
        eventoCSuave = palette['evento/c-suave'],
        eventoC = palette['evento/c'],
        relevoBrilho = palette['relevo/brilho'],
        relevoBrilhoSuave = palette['relevo/brilho-suave'],
        relevoSombraBaixa = palette['relevo/sombra-baixa'],
        relevoSombra = palette['relevo/sombra'],
        relevoSombraCurta = palette['relevo/sombra-curta'],
        relevoSombraForte = palette['relevo/sombra-forte'],
        linha = palette['linha'],
        scrim = palette['scrim'],
        superficieKnob = palette['superficie/knob'],
        superficiePapel = palette['superficie/papel'];

  const AgendaTokens({
    required this.id,
    required this.nome,
    required this.brightness,
    required this.fundoBase,
    required this.fundoMancha1,
    required this.fundoMancha2,
    required this.fundoMancha3,
    required this.fundoMancha4,
    required this.vidroSuave,
    required this.vidroNormal,
    required this.vidroForte,
    required this.vidroBorda,
    required this.campoFundo,
    required this.campoBorda,
    required this.campoLip,
    required this.campoSombra,
    required this.textoPrincipal,
    required this.textoSuave,
    required this.textoFraco,
    required this.acentoBase,
    required this.acentoSuave,
    required this.acentoSobre,
    required this.acentoSombra,
    required this.acentoBrilho,
    required this.acentoBaseEscura,
    required this.estadoErro,
    required this.estadoErroSuave,
    required this.estadoLivre,
    required this.estadoLivreSuave,
    required this.membroA,
    required this.membroB,
    required this.membroC,
    required this.membroCSuave,
    required this.eventoASuave,
    required this.eventoBSuave,
    required this.eventoCSuave,
    required this.eventoC,
    required this.relevoBrilho,
    required this.relevoBrilhoSuave,
    required this.relevoSombraBaixa,
    required this.relevoSombra,
    required this.relevoSombraCurta,
    required this.relevoSombraForte,
    required this.linha,
    required this.scrim,
    required this.superficieKnob,
    required this.superficiePapel,
  });

  final String id;
  final String nome;
  final Brightness brightness;

  final Color fundoBase;
  final Color fundoMancha1;
  final Color fundoMancha2;
  final Color fundoMancha3;
  final Color fundoMancha4;

  final Color vidroSuave;
  final Color vidroNormal;
  final Color vidroForte;
  final Color vidroBorda;

  final Color campoFundo;
  final Color campoBorda;
  final Color campoLip;
  final Color campoSombra;

  final Color textoPrincipal;
  final Color textoSuave;
  final Color textoFraco;

  final Color acentoBase;
  final Color acentoSuave;
  final Color acentoSobre;
  final Color acentoSombra;
  final Color acentoBrilho;
  final Color acentoBaseEscura;

  final Color estadoErro;
  final Color estadoErroSuave;
  final Color estadoLivre;
  final Color estadoLivreSuave;

  final Color membroA;
  final Color membroB;
  final Color membroC;
  final Color membroCSuave;

  final Color eventoASuave;
  final Color eventoBSuave;
  final Color eventoCSuave;
  final Color eventoC;

  final Color relevoBrilho;
  final Color relevoBrilhoSuave;
  final Color relevoSombraBaixa;
  final Color relevoSombra;
  final Color relevoSombraCurta;
  final Color relevoSombraForte;

  final Color linha;
  final Color scrim;
  final Color superficieKnob;
  final Color superficiePapel;

  bool get escuro => brightness == Brightness.dark;

  // Compatibilidade com os widgets já existentes.
  Color get sombraCor => relevoSombraForte;
  Color get sombraAcento => acentoSombra;

  List<BoxShadow> get sombraCartao => [
        BoxShadow(
          color: relevoSombra,
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: relevoSombraCurta,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  List<BoxShadow> get sombraBotao => [
        BoxShadow(
          color: acentoSombra,
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: acentoSombra,
          blurRadius: 3,
          offset: const Offset(0, 2),
        ),
      ];

  Color membro(int i) => [membroA, membroB, membroC][i % 3];

  @override
  AgendaTokens copyWith({
    Color? fundoBase,
    Color? fundoMancha1,
    Color? fundoMancha2,
    Color? fundoMancha3,
    Color? fundoMancha4,
  }) {
    return AgendaTokens(
      id: id,
      nome: nome,
      brightness: brightness,
      fundoBase: fundoBase ?? this.fundoBase,
      fundoMancha1: fundoMancha1 ?? this.fundoMancha1,
      fundoMancha2: fundoMancha2 ?? this.fundoMancha2,
      fundoMancha3: fundoMancha3 ?? this.fundoMancha3,
      fundoMancha4: fundoMancha4 ?? this.fundoMancha4,
      vidroSuave: vidroSuave,
      vidroNormal: vidroNormal,
      vidroForte: vidroForte,
      vidroBorda: vidroBorda,
      campoFundo: campoFundo,
      campoBorda: campoBorda,
      campoLip: campoLip,
      campoSombra: campoSombra,
      textoPrincipal: textoPrincipal,
      textoSuave: textoSuave,
      textoFraco: textoFraco,
      acentoBase: acentoBase,
      acentoSuave: acentoSuave,
      acentoSobre: acentoSobre,
      acentoSombra: acentoSombra,
      acentoBrilho: acentoBrilho,
      acentoBaseEscura: acentoBaseEscura,
      estadoErro: estadoErro,
      estadoErroSuave: estadoErroSuave,
      estadoLivre: estadoLivre,
      estadoLivreSuave: estadoLivreSuave,
      membroA: membroA,
      membroB: membroB,
      membroC: membroC,
      membroCSuave: membroCSuave,
      eventoASuave: eventoASuave,
      eventoBSuave: eventoBSuave,
      eventoCSuave: eventoCSuave,
      eventoC: eventoC,
      relevoBrilho: relevoBrilho,
      relevoBrilhoSuave: relevoBrilhoSuave,
      relevoSombraBaixa: relevoSombraBaixa,
      relevoSombra: relevoSombra,
      relevoSombraCurta: relevoSombraCurta,
      relevoSombraForte: relevoSombraForte,
      linha: linha,
      scrim: scrim,
      superficieKnob: superficieKnob,
      superficiePapel: superficiePapel,
    );
  }

  @override
  AgendaTokens lerp(ThemeExtension<AgendaTokens>? other, double t) {
    if (other is! AgendaTokens) return this;
    return t < 0.5 ? this : other;
  }
}

enum AppThemeId {
  aconchegante,
  azulClaro,
  azulEscuro,
  multicolorClaro,
  roxoRosaEscuro,
}

class AppThemes {
  AppThemes._();

  static final aconchegante = AgendaTokens.fromPalette(
    id: 'aconchegante',
    palette: figma.AppPalette.aconchegante,
  );

  static final azulClaro = AgendaTokens.fromPalette(
    id: 'azul_claro',
    palette: figma.AppPalette.azulClaro,
  );

  static final azulEscuro = AgendaTokens.fromPalette(
    id: 'azul_escuro',
    palette: figma.AppPalette.azulEscuro,
  );

  static final multicolorClaro = AgendaTokens.fromPalette(
    id: 'multicolor_claro',
    palette: figma.AppPalette.multicoloClaro,
  );

  static final roxoRosaEscuro = AgendaTokens.fromPalette(
    id: 'roxo_rosa_escuro',
    palette: figma.AppPalette.roxoRosaEscuro,
  );

  static final todos = <AgendaTokens>[
    aconchegante,
    azulClaro,
    azulEscuro,
    multicolorClaro,
    roxoRosaEscuro,
  ];

  static AgendaTokens byId(AppThemeId id) => todos[id.index];

  static ThemeData build(AgendaTokens t) {
    return ThemeData(
      useMaterial3: true,
      brightness: t.brightness,
      fontFamily: AgendaDims.fonte,
      scaffoldBackgroundColor: t.fundoBase,
      colorScheme: ColorScheme.fromSeed(
        seedColor: t.acentoBase,
        brightness: t.brightness,
      ).copyWith(
        primary: t.acentoBase,
        onPrimary: t.acentoSobre,
        surface: t.fundoBase,
        onSurface: t.textoPrincipal,
        error: t.estadoErro,
      ),
      dividerColor: t.linha,
      splashColor: t.acentoSuave,
      highlightColor: Colors.transparent,
      extensions: <ThemeExtension<dynamic>>[t],
    );
  }
}

extension AgendaThemeContext on BuildContext {
  AgendaTokens get tokens => Theme.of(this).extension<AgendaTokens>()!;
}
