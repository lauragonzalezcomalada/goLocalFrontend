import 'package:flutter/material.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
import 'package:worldwildprova/widgets/homewrapper.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';

import 'settings/settings_controller.dart';
// Importamos el modelo 'Place'
// Necesario para convertir JSON a objetos

// Importamos la pantalla de detalles

const String apiUrl = 'http://127.0.0.1:8000/api/places/';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Django API Flutter',
      theme: AppTheme.lightTheme,
      home: const HomeWrapper(),
    );
  }
}