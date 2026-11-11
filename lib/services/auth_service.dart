import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AuthService {
  static GoTrueClient get _auth => SupabaseService.client.auth;

  static bool get logado => _auth.currentSession != null;
  static User? get usuario => _auth.currentUser;
  static String get uid => _auth.currentUser!.id;
  static String get email => _auth.currentUser?.email ?? '';
  static String get nome =>
      (_auth.currentUser?.userMetadata?['nome'] as String?) ?? 'Usuário';

  static Future<void> entrar(String email, String senha) async {
    await _auth
        .signInWithPassword(email: email.trim(), password: senha)
        .timeout(limiteRede);
  }

  static Future<bool> criarConta({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final res = await _auth.signUp(
      email: email.trim(),
      password: senha,
      data: {'nome': nome.trim()},
    ).timeout(limiteRede);
    return res.session != null;
  }

  /// Tema guardado nos metadados da conta (cópia local da sessão).
  static String? get temaSalvo =>
      _auth.currentUser?.userMetadata?['tema'] as String?;

  /// Tema da conta consultado no servidor; se falhar, usa a cópia local.
  static Future<String?> temaDaConta() async {
    try {
      final r = await _auth.getUser().timeout(limiteRede);
      return r.user?.userMetadata?['tema'] as String?;
    } catch (_) {
      return temaSalvo;
    }
  }

  /// Os metadados são mesclados: o campo 'nome' continua intacto.
  static Future<void> salvarTema(String tema) async {
    await _auth
        .updateUser(UserAttributes(data: {'tema': tema}))
        .timeout(limiteRede);
  }

  static Future<void> sair() => _auth.signOut();
}