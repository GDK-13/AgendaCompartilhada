

import 'package:flutter/material.dart';

import 'controllers/theme_controller.dart';
import 'routes/app_routes.dart';
import 'theme/agenda_theme.dart';

class AgendaApp extends StatelessWidget {
  const AgendaApp({
    super.key,
    required this.themeController,
  });

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeId>(
      valueListenable: themeController,
      builder: (context, themeId, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Agenda Compartilhada',
          theme: AppThemes.build(AppThemes.byId(themeId)),
          initialRoute: AppRoutes.login,
          routes: AppRoutes.routes(themeController: themeController),
        );
      },
    );
  }
}
