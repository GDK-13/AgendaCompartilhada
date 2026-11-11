import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/modelos.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

class CompromissoService {
  static SupabaseClient get _db => SupabaseService.client;

  static String _utc(DateTime d) => d.toUtc().toIso8601String();

  static List<Compromisso> _lista(dynamic rows) => (rows as List)
      .map((r) => Compromisso.fromMap(Map<String, dynamic>.from(r as Map)))
      .toList();

  static Future<List<Compromisso>> doDia(DateTime dia) {
    final ini = DateTime(dia.year, dia.month, dia.day);
    final fim = DateTime(dia.year, dia.month, dia.day + 1);
    return doPeriodo(ini, fim);
  }

  /// Compromissos que cruzam o intervalo [ini, fim).
  static Future<List<Compromisso>> doPeriodo(DateTime ini, DateTime fim) async {
    final rows = await _db
        .from('compromissos')
        .select()
        .lt('inicio', _utc(fim))
        .gt('fim', _utc(ini))
        .order('inicio')
        .timeout(limiteRede);
    return _lista(rows);
  }

  /// Mês exibido no calendário, com uma semana de folga de cada lado para
  /// cobrir os dias vizinhos que o grid também mostra.
  static Future<List<Compromisso>> doMes(DateTime mes) {
    final ini = DateTime(mes.year, mes.month, 1 - 7);
    final fim = DateTime(mes.year, mes.month + 1, 1 + 7);
    return doPeriodo(ini, fim);
  }

  /// Devolve o compromisso criado (precisamos do id para o lembrete local).
  static Future<Compromisso> criar({
    required String titulo,
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final row = await _db
        .from('compromissos')
        .insert({
          'usuario_id': AuthService.uid,
          'titulo': titulo.trim(),
          'inicio': _utc(inicio),
          'fim': _utc(fim),
        })
        .select()
        .single()
        .timeout(limiteRede);
    return Compromisso.fromMap(Map<String, dynamic>.from(row as Map));
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