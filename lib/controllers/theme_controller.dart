import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../theme/agenda_theme.dart';

/// Tema do app. A escolha fica em dois lugares:
///  - neste aparelho (SharedPreferences): vale já na abertura do app e na
///    tela de login, antes de qualquer sessão;
///  - na conta (metadados do usuário no Supabase): acompanha o usuário em
///    outros aparelhos e depois de reinstalar o app.
class ThemeController extends ValueNotifier<AppThemeId> {
  ThemeController() : super(AppThemeId.aconchegante);

  static const _chave = 'tema_id';

  // Evita que uma sincronização sobrescreva uma escolha ainda sendo enviada.
  bool _salvandoConta = false;

  AgendaTokens get tokens => AppThemes.byId(value);

  static AppThemeId? _porNome(String? nome) {
    for (final t in AppThemeId.values) {
      if (t.name == nome) return t;
    }
    return null;
  }

  /// Chame uma vez no main(), antes do runApp.
  Future<void> carregar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      value = _porNome(prefs.getString(_chave)) ?? AppThemeId.aconchegante;
    } catch (e) {
      debugPrint('Erro ao carregar tema: $e');
    }
  }

  Future<void> _salvarLocal(AppThemeId theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chave, theme.name);
    } catch (e) {
      debugPrint('Erro ao salvar tema: $e');
    }
  }

  Future<void> _salvarNaConta(AppThemeId theme) async {
    if (!AuthService.logado) return;
    _salvandoConta = true;
    try {
      await AuthService.salvarTema(theme.name);
    } catch (e) {
      debugPrint('Erro ao salvar tema na conta: $e');
    } finally {
      _salvandoConta = false;
    }
  }

  /// Chame quando houver sessão (ao entrar e ao abrir o app já logado).
  /// Se a conta já tem tema, ele vale; se não tem, leva o do aparelho.
  Future<void> sincronizarComConta() async {
    if (!AuthService.logado || _salvandoConta) return;
    try {
      final remoto = _porNome(await AuthService.temaDaConta());
      if (_salvandoConta) return;
      if (remoto != null) {
        if (remoto != value) value = remoto;
        await _salvarLocal(remoto);
      } else {
        await _salvarNaConta(value);
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar tema: $e');
    }
  }

  Future<void> setTheme(AppThemeId theme) async {
    if (theme == value) return;
    value = theme;
    await _salvarLocal(theme);
    await _salvarNaConta(theme);
  }
}