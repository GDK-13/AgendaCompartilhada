import 'package:flutter/foundation.dart';

import '../theme/agenda_theme.dart';

class ThemeController extends ValueNotifier<AppThemeId> {
  ThemeController() : super(AppThemeId.aconchegante);

  AgendaTokens get tokens => AppThemes.byId(value);

  void setTheme(AppThemeId theme) {
    value = theme;
  }
}
