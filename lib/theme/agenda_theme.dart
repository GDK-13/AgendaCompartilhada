// GERADO a partir do mockup "Agenda Compartilhada".
// Nomes de tokens = variáveis do Figma (fundo-base -> fundoBase, vidro-normal -> vidroNormal, ...).
//
// Uso:
//   MaterialApp(theme: AppThemes.build(AppThemes.aconchegante), ...)
//   final t = Theme.of(context).extension<AgendaTokens>()!;
//   Container(color: t.vidroNormal, ...)
//
// Trocar de tema: guarde um AppThemeId num ValueNotifier/Provider e reconstrua o MaterialApp.

import 'package:flutter/material.dart';

/// Medidas fixas, iguais em todos os temas (extraídas do código exportado do Figma).
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

  static const double desfoqueVidro = 14; // sigma do BackdropFilter
  static const double desfoqueMancha = 35; // sigma das manchas de fundo

  static const String fonte = 'Inter';
}

@immutable
class AgendaTokens extends ThemeExtension<AgendaTokens> {
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
    required this.textoPrincipal,
    required this.textoSuave,
    required this.textoFraco,
    required this.acentoBase,
    required this.acentoSuave,
    required this.acentoSobre,
    required this.estadoErro,
    required this.estadoErroSuave,
    required this.estadoLivre,
    required this.membroA,
    required this.membroB,
    required this.membroC,
    required this.eventoASuave,
    required this.eventoBSuave,
    required this.eventoCSuave,
    required this.eventoC,
    required this.linha,
    required this.scrim,
    required this.superficieKnob,
    required this.superficiePapel,
    required this.sombraCor,
    required this.sombraAcento,
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
  final Color textoPrincipal;
  final Color textoSuave;
  final Color textoFraco;
  final Color acentoBase;
  final Color acentoSuave;
  final Color acentoSobre;
  final Color estadoErro;
  final Color estadoErroSuave;
  final Color estadoLivre;
  final Color membroA;
  final Color membroB;
  final Color membroC;
  final Color eventoASuave;
  final Color eventoBSuave;
  final Color eventoCSuave;
  final Color eventoC;
  final Color linha;
  final Color scrim;
  final Color superficieKnob;
  final Color superficiePapel;
  final Color sombraCor;
  final Color sombraAcento;

  bool get escuro => brightness == Brightness.dark;

  /// Cartões de vidro: duas camadas de sombra (ampla + curta).
  List<BoxShadow> get sombraCartao => [
        BoxShadow(color: sombraCor.withValues(alpha: escuro ? 0.45 : 0.16), blurRadius: 28, offset: const Offset(0, 10)),
        BoxShadow(color: sombraCor.withValues(alpha: escuro ? 0.30 : 0.10), blurRadius: 6, offset: const Offset(0, 2)),
      ];

  /// Botão primário com relevo.
  List<BoxShadow> get sombraBotao => [
        BoxShadow(color: sombraAcento.withValues(alpha: escuro ? 0.45 : 0.38), blurRadius: 16, offset: const Offset(0, 8)),
        BoxShadow(color: sombraAcento.withValues(alpha: escuro ? 0.35 : 0.38), blurRadius: 3, offset: const Offset(0, 2)),
      ];

  /// Cor fixa de cada membro do grupo (índice 0 = Kevin, 1 = Ana, 2 = Bruno).
  Color membro(int i) => [membroA, membroB, membroC][i % 3];

  @override
  AgendaTokens copyWith({
    Color? fundoBase,
    Color? fundoMancha1,
    Color? fundoMancha2,
    Color? fundoMancha3,
    Color? fundoMancha4,
    Color? vidroSuave,
    Color? vidroNormal,
    Color? vidroForte,
    Color? vidroBorda,
    Color? campoFundo,
    Color? campoBorda,
    Color? textoPrincipal,
    Color? textoSuave,
    Color? textoFraco,
    Color? acentoBase,
    Color? acentoSuave,
    Color? acentoSobre,
    Color? estadoErro,
    Color? estadoErroSuave,
    Color? estadoLivre,
    Color? membroA,
    Color? membroB,
    Color? membroC,
    Color? eventoASuave,
    Color? eventoBSuave,
    Color? eventoCSuave,
    Color? eventoC,
    Color? linha,
    Color? scrim,
    Color? superficieKnob,
    Color? superficiePapel,
    Color? sombraCor,
    Color? sombraAcento,
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
      vidroSuave: vidroSuave ?? this.vidroSuave,
      vidroNormal: vidroNormal ?? this.vidroNormal,
      vidroForte: vidroForte ?? this.vidroForte,
      vidroBorda: vidroBorda ?? this.vidroBorda,
      campoFundo: campoFundo ?? this.campoFundo,
      campoBorda: campoBorda ?? this.campoBorda,
      textoPrincipal: textoPrincipal ?? this.textoPrincipal,
      textoSuave: textoSuave ?? this.textoSuave,
      textoFraco: textoFraco ?? this.textoFraco,
      acentoBase: acentoBase ?? this.acentoBase,
      acentoSuave: acentoSuave ?? this.acentoSuave,
      acentoSobre: acentoSobre ?? this.acentoSobre,
      estadoErro: estadoErro ?? this.estadoErro,
      estadoErroSuave: estadoErroSuave ?? this.estadoErroSuave,
      estadoLivre: estadoLivre ?? this.estadoLivre,
      membroA: membroA ?? this.membroA,
      membroB: membroB ?? this.membroB,
      membroC: membroC ?? this.membroC,
      eventoASuave: eventoASuave ?? this.eventoASuave,
      eventoBSuave: eventoBSuave ?? this.eventoBSuave,
      eventoCSuave: eventoCSuave ?? this.eventoCSuave,
      eventoC: eventoC ?? this.eventoC,
      linha: linha ?? this.linha,
      scrim: scrim ?? this.scrim,
      superficieKnob: superficieKnob ?? this.superficieKnob,
      superficiePapel: superficiePapel ?? this.superficiePapel,
      sombraCor: sombraCor ?? this.sombraCor,
      sombraAcento: sombraAcento ?? this.sombraAcento,
    );
  }

  @override
  AgendaTokens lerp(ThemeExtension<AgendaTokens>? other, double t) {
    if (other is! AgendaTokens) return this;
    final d = t < 0.5 ? this : other;
    return AgendaTokens(
      id: d.id,
      nome: d.nome,
      brightness: d.brightness,
      fundoBase: Color.lerp(fundoBase, other.fundoBase, t)!,
      fundoMancha1: Color.lerp(fundoMancha1, other.fundoMancha1, t)!,
      fundoMancha2: Color.lerp(fundoMancha2, other.fundoMancha2, t)!,
      fundoMancha3: Color.lerp(fundoMancha3, other.fundoMancha3, t)!,
      fundoMancha4: Color.lerp(fundoMancha4, other.fundoMancha4, t)!,
      vidroSuave: Color.lerp(vidroSuave, other.vidroSuave, t)!,
      vidroNormal: Color.lerp(vidroNormal, other.vidroNormal, t)!,
      vidroForte: Color.lerp(vidroForte, other.vidroForte, t)!,
      vidroBorda: Color.lerp(vidroBorda, other.vidroBorda, t)!,
      campoFundo: Color.lerp(campoFundo, other.campoFundo, t)!,
      campoBorda: Color.lerp(campoBorda, other.campoBorda, t)!,
      textoPrincipal: Color.lerp(textoPrincipal, other.textoPrincipal, t)!,
      textoSuave: Color.lerp(textoSuave, other.textoSuave, t)!,
      textoFraco: Color.lerp(textoFraco, other.textoFraco, t)!,
      acentoBase: Color.lerp(acentoBase, other.acentoBase, t)!,
      acentoSuave: Color.lerp(acentoSuave, other.acentoSuave, t)!,
      acentoSobre: Color.lerp(acentoSobre, other.acentoSobre, t)!,
      estadoErro: Color.lerp(estadoErro, other.estadoErro, t)!,
      estadoErroSuave: Color.lerp(estadoErroSuave, other.estadoErroSuave, t)!,
      estadoLivre: Color.lerp(estadoLivre, other.estadoLivre, t)!,
      membroA: Color.lerp(membroA, other.membroA, t)!,
      membroB: Color.lerp(membroB, other.membroB, t)!,
      membroC: Color.lerp(membroC, other.membroC, t)!,
      eventoASuave: Color.lerp(eventoASuave, other.eventoASuave, t)!,
      eventoBSuave: Color.lerp(eventoBSuave, other.eventoBSuave, t)!,
      eventoCSuave: Color.lerp(eventoCSuave, other.eventoCSuave, t)!,
      eventoC: Color.lerp(eventoC, other.eventoC, t)!,
      linha: Color.lerp(linha, other.linha, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      superficieKnob: Color.lerp(superficieKnob, other.superficieKnob, t)!,
      superficiePapel: Color.lerp(superficiePapel, other.superficiePapel, t)!,
      sombraCor: Color.lerp(sombraCor, other.sombraCor, t)!,
      sombraAcento: Color.lerp(sombraAcento, other.sombraAcento, t)!,
    );
  }
}

enum AppThemeId { aconchegante, azul_claro, azul_escuro, lilas_azul_verde, ameixa }

class AppThemes {
  AppThemes._();

  static const aconchegante = AgendaTokens(
    id: 'aconchegante',
    nome: 'Aconchegante',
    brightness: Brightness.light,
    fundoBase: Color(0xFFF4EADF),
    fundoMancha1: Color(0x99E8A07F),
    fundoMancha2: Color(0x99A9C1A3),
    fundoMancha3: Color(0x8CEFC66F),
    fundoMancha4: Color(0x72DDA0A0),
    vidroSuave: Color(0x6BFFFFFF),
    vidroNormal: Color(0x80FFFFFF),
    vidroForte: Color(0x99FFFFFF),
    vidroBorda: Color(0xA6FFFFFF),
    campoFundo: Color(0xB2E9D9C6),
    campoBorda: Color(0x99D6C2AA),
    textoPrincipal: Color(0xFF4A3426),
    textoSuave: Color(0xFF8B735F),
    textoFraco: Color(0x7F4A3426),
    acentoBase: Color(0xFFC8694A),
    acentoSuave: Color(0x38C8694A),
    acentoSobre: Color(0xFFFFFFFF),
    estadoErro: Color(0xFFC0483A),
    estadoErroSuave: Color(0x38C0483A),
    estadoLivre: Color(0xFF8FAA8B),
    membroA: Color(0xFFD9825F),
    membroB: Color(0xFF8FAA8B),
    membroC: Color(0xFF7B93AD),
    eventoASuave: Color(0x80D9825F),
    eventoBSuave: Color(0x808FAA8B),
    eventoCSuave: Color(0x80E3B04B),
    eventoC: Color(0xFFE3B04B),
    linha: Color(0x1F4A3426),
    scrim: Color(0x592A1A10),
    superficieKnob: Color(0xFFFFFDF8),
    superficiePapel: Color(0xFFFFF8EE),
    sombraCor: Color(0xFF5A3A24),
    sombraAcento: Color(0xFF7A3A22),
  );

  static const azul_claro = AgendaTokens(
    id: 'azul_claro',
    nome: 'Azul claro',
    brightness: Brightness.light,
    fundoBase: Color(0xFFEAF1FB),
    fundoMancha1: Color(0x8CA9C6F2),
    fundoMancha2: Color(0x8CC5D8F6),
    fundoMancha3: Color(0x80B3CCF1),
    fundoMancha4: Color(0x80D3E2F8),
    vidroSuave: Color(0x6BFFFFFF),
    vidroNormal: Color(0x80FFFFFF),
    vidroForte: Color(0x99FFFFFF),
    vidroBorda: Color(0xA6FFFFFF),
    campoFundo: Color(0xB2DCE7F6),
    campoBorda: Color(0x99B9CBE6),
    textoPrincipal: Color(0xFF23364F),
    textoSuave: Color(0xFF5F7391),
    textoFraco: Color(0x8023364F),
    acentoBase: Color(0xFF5C86D6),
    acentoSuave: Color(0x385C86D6),
    acentoSobre: Color(0xFFFFFFFF),
    estadoErro: Color(0xFFD0645F),
    estadoErroSuave: Color(0x38D0645F),
    estadoLivre: Color(0xFF6FB3A0),
    membroA: Color(0xFF5C86D6),
    membroB: Color(0xFF6FB3A0),
    membroC: Color(0xFF9A8FD0),
    eventoASuave: Color(0x805C86D6),
    eventoBSuave: Color(0x806FB3A0),
    eventoCSuave: Color(0x806FB3A0),
    eventoC: Color(0xFF6FB3A0),
    linha: Color(0x1F23364F),
    scrim: Color(0x66101B2D),
    superficieKnob: Color(0xFFFBFDFF),
    superficiePapel: Color(0xFFF4F8FE),
    sombraCor: Color(0xFF2C4A78),
    sombraAcento: Color(0xFF2C4A78),
  );

  static const azul_escuro = AgendaTokens(
    id: 'azul_escuro',
    nome: 'Azul escuro',
    brightness: Brightness.dark,
    fundoBase: Color(0xFF1B2433),
    fundoMancha1: Color(0x663E5F96),
    fundoMancha2: Color(0x732F4A75),
    fundoMancha3: Color(0x4C4A6FA8),
    fundoMancha4: Color(0x6635507F),
    vidroSuave: Color(0x0DFFFFFF),
    vidroNormal: Color(0x14FFFFFF),
    vidroForte: Color(0x1FFFFFFF),
    vidroBorda: Color(0x29FFFFFF),
    campoFundo: Color(0x12FFFFFF),
    campoBorda: Color(0x24FFFFFF),
    textoPrincipal: Color(0xFFE4EAF4),
    textoSuave: Color(0xFFA4B1C6),
    textoFraco: Color(0x73E4EAF4),
    acentoBase: Color(0xFF7FA3E0),
    acentoSuave: Color(0x387FA3E0),
    acentoSobre: Color(0xFF12203A),
    estadoErro: Color(0xFFE08A84),
    estadoErroSuave: Color(0x38E08A84),
    estadoLivre: Color(0xFF78C0AE),
    membroA: Color(0xFF7FA3E0),
    membroB: Color(0xFF78C0AE),
    membroC: Color(0xFFA99BE0),
    eventoASuave: Color(0x807FA3E0),
    eventoBSuave: Color(0x8078C0AE),
    eventoCSuave: Color(0x8078C0AE),
    eventoC: Color(0xFF78C0AE),
    linha: Color(0x1AFFFFFF),
    scrim: Color(0x80000000),
    superficieKnob: Color(0xFFF2F5FA),
    superficiePapel: Color(0xFF232E42),
    sombraCor: Color(0xFF000000),
    sombraAcento: Color(0xFF000000),
  );

  static const lilas_azul_verde = AgendaTokens(
    id: 'lilas_azul_verde',
    nome: 'Lilás, azul e verde',
    brightness: Brightness.light,
    fundoBase: Color(0xFFF7F5FC),
    fundoMancha1: Color(0x80B9A6E8),
    fundoMancha2: Color(0x80A9C7EE),
    fundoMancha3: Color(0x80A8D8C4),
    fundoMancha4: Color(0x99E5DDF6),
    vidroSuave: Color(0x6BFFFFFF),
    vidroNormal: Color(0x80FFFFFF),
    vidroForte: Color(0x99FFFFFF),
    vidroBorda: Color(0xA6FFFFFF),
    campoFundo: Color(0xB2EAE4F6),
    campoBorda: Color(0x99D2C8E8),
    textoPrincipal: Color(0xFF2E2547),
    textoSuave: Color(0xFF6E6490),
    textoFraco: Color(0x802E2547),
    acentoBase: Color(0xFF8068C8),
    acentoSuave: Color(0x388068C8),
    acentoSobre: Color(0xFFFFFFFF),
    estadoErro: Color(0xFFCF5F6E),
    estadoErroSuave: Color(0x38CF5F6E),
    estadoLivre: Color(0xFF5FAE93),
    membroA: Color(0xFF8068C8),
    membroB: Color(0xFF5FAE93),
    membroC: Color(0xFF6A9AD6),
    eventoASuave: Color(0x808068C8),
    eventoBSuave: Color(0x805FAE93),
    eventoCSuave: Color(0x805FAE93),
    eventoC: Color(0xFF5FAE93),
    linha: Color(0x1F2E2547),
    scrim: Color(0x661E1530),
    superficieKnob: Color(0xFFFFFEFF),
    superficiePapel: Color(0xFFFBF9FE),
    sombraCor: Color(0xFF4A3A7A),
    sombraAcento: Color(0xFF4A3A7A),
  );

  static const ameixa = AgendaTokens(
    id: 'ameixa',
    nome: 'Ameixa',
    brightness: Brightness.dark,
    fundoBase: Color(0xFF241B2F),
    fundoMancha1: Color(0x666B4F9C),
    fundoMancha2: Color(0x52B8648F),
    fundoMancha3: Color(0x528A6FBF),
    fundoMancha4: Color(0x804B3566),
    vidroSuave: Color(0x0DFFFFFF),
    vidroNormal: Color(0x14FFFFFF),
    vidroForte: Color(0x1FFFFFFF),
    vidroBorda: Color(0x29FFFFFF),
    campoFundo: Color(0x12FFFFFF),
    campoBorda: Color(0x24FFFFFF),
    textoPrincipal: Color(0xFFF0E6F3),
    textoSuave: Color(0xFFB8A6C4),
    textoFraco: Color(0x73F0E6F3),
    acentoBase: Color(0xFFD98AB0),
    acentoSuave: Color(0x38D98AB0),
    acentoSobre: Color(0xFF2A1A33),
    estadoErro: Color(0xFFE0817F),
    estadoErroSuave: Color(0x38E0817F),
    estadoLivre: Color(0xFF7FC8A9),
    membroA: Color(0xFFD98AB0),
    membroB: Color(0xFF9A7BD0),
    membroC: Color(0xFFC3B1E8),
    eventoASuave: Color(0x80D98AB0),
    eventoBSuave: Color(0x809A7BD0),
    eventoCSuave: Color(0x807FC8A9),
    eventoC: Color(0xFF7FC8A9),
    linha: Color(0x1AFFFFFF),
    scrim: Color(0x80000000),
    superficieKnob: Color(0xFFF5EEF7),
    superficiePapel: Color(0xFF2E2340),
    sombraCor: Color(0xFF000000),
    sombraAcento: Color(0xFF000000),
  );

  static const todos = <AgendaTokens>[aconchegante, azul_claro, azul_escuro, lilas_azul_verde, ameixa];

  static AgendaTokens byId(AppThemeId id) => todos[id.index];

  /// ThemeData completo para o MaterialApp, com os tokens anexados como extensão.
  static ThemeData build(AgendaTokens t) {
    final base = t.escuro ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: t.fundoBase,
      colorScheme: ColorScheme(
        brightness: t.brightness,
        primary: t.acentoBase,
        onPrimary: t.acentoSobre,
        secondary: t.estadoLivre,
        onSecondary: t.acentoSobre,
        error: t.estadoErro,
        onError: Colors.white,
        surface: t.superficiePapel,
        onSurface: t.textoPrincipal,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: AgendaDims.fonte,
        bodyColor: t.textoPrincipal,
        displayColor: t.textoPrincipal,
      ),
      dividerColor: t.linha,
      extensions: <ThemeExtension<dynamic>>[t],
    );
  }
}

extension AgendaThemeContext on BuildContext {
  AgendaTokens get tokens => Theme.of(this).extension<AgendaTokens>()!;
}
