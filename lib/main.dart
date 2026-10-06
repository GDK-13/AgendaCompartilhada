import 'package:flutter/material.dart';

import 'app.dart';
import 'controllers/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AgendaApp(themeController: ThemeController()));
}
