import 'package:flutter/material.dart';

import '../controllers/theme_controller.dart';
import '../screens/auth_screen.dart';
import '../screens/event_form_screen.dart';
import '../screens/group_form_screen.dart';
import '../screens/home_shell.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const login = '/';
  static const home = '/home';
  static const eventForm = '/eventForm';
  static const groupForm = '/groupForm';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> routes({
    required ThemeController themeController,
  }) {
    return {
      login: (_) => const AuthScreen(),
      home: (_) => HomeShell(themeController: themeController),
      eventForm: (_) => const EventFormScreen(),
      groupForm: (_) => const GroupFormScreen(),
      settings: (_) => SettingsScreen(themeController: themeController),
    };
  }
}
