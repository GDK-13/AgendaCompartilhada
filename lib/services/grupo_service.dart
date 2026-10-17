import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/modelos.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

class GrupoService {
  static SupabaseClient get _db => SupabaseService.client;

  static String _utc(DateTime d) => d.toUtc().toIso8601String();

  static List<Map<String, dynamic>> _lista(dynamic rows) => (rows as List)
      .map((r) => Map<String, dynamic>.from(r as Map))
      .toList();

  static Future<List<Grupo>> listar() async {
    final rows = await _db
        .from('grupos')
        .select('id, nome, codigo, participacoes(count)')
        .order('criado_em');
    return _lista(rows).map(Grupo.fromMap).toList();
  }

  static Future<Grupo> criar(String nome) async {
    final row = await _db
        .from('grupos')
        .insert({'nome': nome.trim(), 'criador_id': AuthService.uid})
        .select('id, nome, codigo')
        .single();
    return Grupo.fromMap(Map<String, dynamic>.from(row as Map));
  }

  static Future<String> entrar(String codigo) async {
    final id = await _db.rpc('entrar_grupo', params: {'p_codigo': codigo});
    return id as String;
  }

  static Future<List<Ocupacao>> ocupacoes(
    String grupoId,
    DateTime inicio,
    DateTime fim,
  ) async {
    final rows = await _db.rpc('ocupacoes_do_grupo', params: {
      'p_grupo_id': grupoId,
      'p_inicio': _utc(inicio),
      'p_fim': _utc(fim),
    });
    return _lista(rows).map(Ocupacao.fromMap).toList();
  }

  static Future<List<Intervalo>> horariosLivres(
    String grupoId,
    DateTime inicio,
    DateTime fim, {
    int duracaoMinutos = 60,
  }) async {
    final rows = await _db.rpc('horarios_livres_do_grupo', params: {
      'p_grupo_id': grupoId,
      'p_inicio': _utc(inicio),
      'p_fim': _utc(fim),
      'p_duracao_minutos': duracaoMinutos,
    });
    return _lista(rows).map(Intervalo.fromMap).toList();
  }
}
