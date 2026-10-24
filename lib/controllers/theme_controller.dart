import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/agenda_theme.dart';

class ThemeController extends ValueNotifier<AppThemeId> {
  ThemeController() : super(AppThemeId.aconchegante);

  static const _chave = 'tema_id';

  AgendaTokens get tokens => AppThemes.byId(value);

  /// Chame uma vez no main(), antes do runApp.
  Future<void> carregar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nome = prefs.getString(_chave);
      value = AppThemeId.values.firstWhere(
        (t) => t.name == nome,
        orElse: () => AppThemeId.aconchegante,
      );
    } catch (e) {
      debugPrint('Erro ao carregar tema: $e');
    }
  }

  Future<void> setTheme(AppThemeId theme) async {
    if (theme == value) return;
    value = theme;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chave, theme.name);
    } catch (e) {
      debugPrint('Erro ao salvar tema: $e');
    }
  }
}