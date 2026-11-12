import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/modelos.dart';
import 'auth_service.dart';
import 'convite_service.dart';
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
        .select('id, nome, codigo, exclui_em, participacoes(count)')
        .order('criado_em')
        .timeout(limiteRede);
    return _lista(rows).map(Grupo.fromMap).toList();
  }

  static Future<Grupo> criar(String nome) async {
    final row = await _db
        .from('grupos')
        .insert({'nome': nome.trim(), 'criador_id': AuthService.uid})
        .select('id, nome, codigo')
        .single()
        .timeout(limiteRede);
    return Grupo.fromMap(Map<String, dynamic>.from(row as Map));
  }

  /// Aceita o código puro, o link de convite ou a mensagem inteira colada.
  static Future<String> entrar(String entrada) async {
    final codigo = ConviteService.extrairCodigo(entrada) ?? entrada.trim();
    final id = await _db
        .rpc('entrar_grupo', params: {'p_codigo': codigo})
        .timeout(limiteRede);
    return id as String;
  }

  /// Sai do grupo. Os demais membros recebem um aviso; se ficar só um, o grupo
  /// ganha prazo de exclusão; se não sobrar ninguém, é excluído na hora.
  static Future<void> sair(String grupoId) async {
    await _db.rpc('sair_grupo', params: {
      'p_grupo_id': grupoId,
      'p_nome': AuthService.nome,
    }).timeout(limiteRede);
  }

  /// Avisos de grupo ainda não mostrados neste usuário.
  static Future<List<AvisoGrupo>> avisosPendentes() async {
    final rows = await _db
        .from('avisos')
        .select('id, titulo, mensagem')
        .eq('lido', false)
        .order('criado_em')
        .timeout(limiteRede);
    return _lista(rows).map(AvisoGrupo.fromMap).toList();
  }

  static Future<void> marcarAvisosLidos(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db
        .from('avisos')
        .update({'lido': true})
        .inFilter('id', ids)
        .timeout(limiteRede);
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
    }).timeout(limiteRede);
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
    }).timeout(limiteRede);
    return _lista(rows).map(Intervalo.fromMap).toList();
  }
}