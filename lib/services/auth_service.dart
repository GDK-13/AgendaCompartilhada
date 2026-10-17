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
    await _auth.signInWithPassword(email: email.trim(), password: senha);
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
    );
    return res.session != null;
  }

  static Future<void> sair() => _auth.signOut();
}
