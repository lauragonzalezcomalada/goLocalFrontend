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
    print('uri: $_pendingDeepLink');
    return MaterialApp(
        title: 'Django API Flutter',
        theme: AppTheme.lightTheme,
        home: HomeWrapper(initialDeepLink: _pendingDeepLink)
        //routerConfig: crearRouter(authService, initialLocation: _initialLocation),
        );
  }
}

//coses del GO ROUTER ANTERIOR

  // String? _initialLocation;
  /*late GoRouter _router;
  bool _routerInitialized = false;*/
/*
  @override
  void initState() {
    super.initState();
    _initRouter();
  }

  Future<void> _initRouter() async {
    final deepLink = await getInitialDeepLink();
    setState(() {
      initialLocation = deepLink;
      _routerInitialized = true;
    });
  }*/
  /*@override
  void initState() {
    super.initState();
    _loadInitialDeepLink();
  }*/

  /*Future<void> _loadInitialDeepLink() async {
    const channel = MethodChannel('com.worldwildprova.deeplink');
    try {
      final String? link = await channel.invokeMethod('getInitialLink');
      print('📲 Link desde plataforma: $link');
      if (link != null && link.startsWith('golocal://')) {
        final uri = Uri.parse(link);
        setState(() {
          _initialLocation = '/' +
              link
                  .replaceFirst('golocal://', '')
                  .replaceAll(RegExp(r'/+$'), '');
        });
      } else {
        setState(() {
          _initialLocation = '/'; // fallback si no hay link
        });
      }
    } catch (e) {
      print('⚠️ Error obteniendo deep link: $e');
      setState(() {
        _initialLocation = '/'; // fallback
      });
    }
  }*/
  /*Future<String?> getInitialDeepLink() async {
    const channel = MethodChannel('com.worldwildprova.deeplink');
    try {
      final String? link = await channel.invokeMethod('getInitialLink');
      if (link != null && link.startsWith('golocal://')) {
        final uri = Uri.parse(link);
        return uri.path; // Devuelve /i/xyz123, por ejemplo
      }
    } catch (e) {
      print('Error obteniendo deep link: $e');
    }
    return null;
  }*/

  /* @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Mientras se carga el router
    if (!_routerInitialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    print('Initial Location para GoRouter: $initialLocation');

    _router = crearRouter(authService, initialLocation: initialLocation);
    print('después de crear para GoRouter: $initialLocation');

    return MaterialApp.router(
      title: 'Django API Flutter',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }*/

//EN EL BUILD
 /* final authService = Provider.of<AuthService>(context);

    // Esperar a que _initialLocation esté cargado
    if (_initialLocation == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    print('📍 Inicializando GoRouter con $_initialLocation');*/
