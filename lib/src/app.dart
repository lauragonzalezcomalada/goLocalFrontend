import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/router.dart';
import 'package:worldwildprova/screens/log_in_screen.dart';
import 'package:worldwildprova/screens/profile_screen.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:worldwildprova/widgets/homewrapper.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/privatePlanDetail.dart';

import 'settings/settings_controller.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  Uri? _pendingDeepLink;

  @override
  void initState() {
    super.initState();
    _appLinks.uriLinkStream.listen((uri) {
      if (uri != null && mounted) {
        setState(() {
          _pendingDeepLink = uri;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Django API Flutter',
      theme: AppTheme.lightTheme,
      home: HomeWrapper(initialDeepLink: _pendingDeepLink),
      debugShowCheckedModeBanner: false,
      //routerConfig: crearRouter(authService, initialLocation: _initialLocation),
    );
  }
}
