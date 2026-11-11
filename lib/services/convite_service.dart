import '../models/modelos.dart';

class ConviteService {
  static const _esquema = 'agenda';
  static const _host = 'convite';

  static const dominioWeb = 'gdk-13.github.io';
  static const caminhoWeb = '/agenda-convite';

  static String? pendente;

  static final _regexLink = RegExp(
    r'(?:' +
        _esquema +
        r'://' +
        _host +
        r'|https://' +
        RegExp.escape(dominioWeb) +
        RegExp.escape(caminhoWeb) +
        r')/?\?codigo=([^\s&#]+)',
  );

  static String gerarLink(String codigo) => Uri(
        scheme: 'https',
        host: dominioWeb,
        path: '$caminhoWeb/',
        queryParameters: {'codigo': codigo},
      ).toString();

  static String gerarLinkApp(String codigo) => Uri(
        scheme: _esquema,
        host: _host,
        queryParameters: {'codigo': codigo},
      ).toString();

  static String mensagem(Grupo g) =>
      'Entre no grupo "${g.nome}" na Agenda Compartilhada!\n\n'
      '${gerarLink(g.codigo)}\n\n'
      'Se o link não abrir, use o código: ${g.codigo}';

  static String? extrairCodigo(String entrada) {
    final txt = entrada.trim();
    if (txt.isEmpty) return null;
    final m = _regexLink.firstMatch(txt);
    if (m != null) return Uri.decodeComponent(m.group(1)!);
    if (txt.contains('://') || txt.contains(RegExp(r'\s'))) return null;
    return txt;
  }
}