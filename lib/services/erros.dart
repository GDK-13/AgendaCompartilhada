import 'package:supabase_flutter/supabase_flutter.dart';

String traduzirErro(Object e) {
  if (e is AuthException) {
    final m = e.message.toLowerCase();
    if (m.contains('invalid login')) return 'E-mail ou senha incorretos.';
    if (m.contains('not confirmed')) return 'Confirme seu e-mail antes de entrar.';
    if (m.contains('already registered')) return 'Este e-mail já tem conta.';
    if (m.contains('password')) return 'A senha precisa ter pelo menos 6 caracteres.';
    return e.message;
  }
  if (e is PostgrestException) {
    if (e.code == '22023' || e.code == '42501' || e.code == '28000') {
      return e.message;
    }
    if (e.code == '23514') return 'Dados inválidos: confira título e horários.';
    return 'Não foi possível concluir a operação. Tente novamente.';
  }
  final s = e.toString();
  if (s.contains('SocketException') || s.contains('ClientException') || s.contains('Failed host lookup')) {
    return 'Sem conexão com a internet. Verifique a rede e tente de novo.';
  }
  return 'Algo deu errado. Tente novamente.';
}
