import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
// Importar la segunda pantalla

void main() async {
  // Set up the SettingsController, which w
  //ill glue user settings to multiple
  // Flutter Widgets.
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MyApp(settingsController: settingsController)));
}
