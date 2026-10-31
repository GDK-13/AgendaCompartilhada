import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/modelos.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

class CompromissoService {
  static SupabaseClient get _db => SupabaseService.client;

  static String _utc(DateTime d) => d.toUtc().toIso8601String();

  static Future<List<Compromisso>> doDia(DateTime dia) async {
    final ini = DateTime(dia.year, dia.month, dia.day);
    final fim = DateTime(dia.year, dia.month, dia.day + 1);
    final rows = await _db
        .from('compromissos')
        .select()
        .lt('inicio', _utc(fim))
        .gt('fim', _utc(ini))
        .order('inicio')
        .timeout(limiteRede);
    return (rows as List)
        .map((r) => Compromisso.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  static Future<void> criar({
    required String titulo,
    required DateTime inicio,
    required DateTime fim,
  }) async {
    await _db.from('compromissos').insert({
      'usuario_id': AuthService.uid,
      'titulo': titulo.trim(),
      'inicio': _utc(inicio),
      'fim': _utc(fim),
    }).timeout(limiteRede);
  }

  static Future<void> atualizar({
    required String id,
    required String titulo,
    required DateTime inicio,
    required DateTime fim,
  }) async {
    await _db.from('compromissos').update({
      'titulo': titulo.trim(),
      'inicio': _utc(inicio),
      'fim': _utc(fim),
    }).eq('id', id).timeout(limiteRede);
  }

  static Future<void> excluir(String id) async {
    await _db.from('compromissos').delete().eq('id', id).timeout(limiteRede);
  }
}
