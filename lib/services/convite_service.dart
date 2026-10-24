import '../models/modelos.dart';

class ConviteService {
  static const _esquema = 'agenda';
  static const _host = 'convite';

  /// Código recebido por link enquanto o usuário ainda não estava logado.
  static String? pendente;

  static final _regexLink = RegExp('$_esquema://$_host\\?codigo=([^\\s&]+)');

  /// Ex.: agenda://convite?codigo=ABC123
  static String gerarLink(String codigo) => Uri(
        scheme: _esquema,
        host: _host,
        queryParameters: {'codigo': codigo},
      ).toString();

  static String mensagem(Grupo g) =>
      'Entre no grupo "${g.nome}" na Agenda Compartilhada!\n\n'
      'Código: ${g.codigo}\n'
      'Link: ${gerarLink(g.codigo)}';

  /// Aceita link, mensagem colada inteira ou o código puro.
  static String? extrairCodigo(String entrada) {
    final txt = entrada.trim();
    if (txt.isEmpty) return null;
    final m = _regexLink.firstMatch(txt);
    if (m != null) return Uri.decodeComponent(m.group(1)!);
    if (txt.contains('://') || txt.contains(RegExp(r'\s'))) return null;
    return txt;
  }
}