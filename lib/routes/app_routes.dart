import 'package:flutter/material.dart';

import '../controllers/theme_controller.dart';
import '../screens/auth_screen.dart';
import '../screens/event_detail_screen.dart';
import '../screens/event_form_screen.dart';
import '../screens/group_form_screen.dart';
import '../screens/group_screen.dart';
import '../screens/home_shell.dart';
import '../screens/settings_screen.dart';
import '../screens/signup_screen.dart';

class AppRoutes {
  static const login = '/';
  static const signup = '/signup';
  static const home = '/home';
  static const eventForm = '/eventForm';
  static const eventDetail = '/eventDetail';
  static const groupForm = '/groupForm';
  static const groupDetail = '/groupDetail';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> routes({
    required ThemeController themeController,
  }) {
    return {
      login: (_) => const AuthScreen(),
      signup: (_) => const SignupScreen(),
      home: (_) => HomeShell(themeController: themeController),
      eventForm: (_) => const EventFormScreen(),
      eventDetail: (_) => const EventDetailScreen(),
      groupForm: (_) => const GroupFormScreen(),
      groupDetail: (_) => const GroupScreen(),
      settings: (_) => SettingsScreen(themeController: themeController),
    };
  }
}
