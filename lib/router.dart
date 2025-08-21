/*import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:worldwildprova/screens/activitydetail_screen.dart';
import 'package:worldwildprova/screens/log_in_screen.dart';
import 'package:worldwildprova/screens/profile_screen.dart';
import 'package:worldwildprova/screens/sign_in_screen.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:worldwildprova/widgets/homewrapper.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/privatePlanDetail.dart';

GoRouter crearRouter(AuthService authService, {String? initialLocation}) {
  print('🚀 Router creado con initialLocation: $initialLocation');

  var goRouter = GoRouter(
    initialLocation: initialLocation ?? '/',
    debugLogDiagnostics: true,
    refreshListenable: authService,
    routes: [
      //LOGIN SCREEN
      GoRoute(
        path: '/login',
        builder: (context, state) {
          print('GO ROUTE: ${state.uri.toString()}');
          final redirectTo = state.uri.queryParameters['redirectTo'];
          return LogInScreen(
            comingFromOnboarding: false,
            redirectTo: redirectTo,
          );
        },
      ),

      GoRoute(
        path: '/test',
        name: '/test',
        builder: (context, state) {
          print('TEST GO ROUTE: ${state.uri.toString()}');
          return ActivityDetail(
              activityUuid: '5bf44b2b-1a74-4a47-9034-29f65a01e7e2',
              userToken:
                  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzUyNTg4NTk0LCJpYXQiOjE3NTI1ODgyOTQsImp0aSI6IjYxNWNmZDk3YTA3YjRkZTU5NWFiYzdmMjFkM2ExZmNiIiwidXNlcl9pZCI6MzN9.O6xeGxClq2Rhc2-HZsAoKW_qHza2AxYagTyQWdlb3js');
        },
      ),
      GoRoute(
          path: '/i',
          builder: (context, state) => MainScaffold(
                initialIndex: 2,
              ) // O cualquier pantalla sencilla
          ),

      //PROFILE SCREEN
      GoRoute(
        path: '/profile/:userUuid',
        name: 'profile',
        builder: (context, state) {
          print('GO ROUTE: ${state.uri.toString()}');
          final userUuid = state.pathParameters['userUuid']!;
          return ProfileScreen(foreignUserUuid: userUuid);
        },
      ),
      //SIGN IN SCREEN
      GoRoute(
        path: '/sign_in',
        name: 'sign_in',
        builder: (context, state) {
          print('SIGN IN PAGE GO ROUTE: ${state.uri.toString()}');
          return SignInScreen();
        },
      ),
      //MAIN SCAFFOLD
      GoRoute(
        path: '/',
        builder: (context, state) {
          print('🎯 Entrando a ruta / con URI: ${state.uri}');
          /* final extra = state.extra as Map<String, dynamic>? ?? {};
          final initialIndex = extra['initialIndex'] as int? ?? 0;
          return MainScaffold(initialIndex: initialIndex);*/

          return const HomeWrapper();
        },
      ),
    ],
    errorBuilder: (context, state) {
      print('❌ Ruta no encontrada: ${state.uri}');
      return Scaffold(
        body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
      );
    },
  );
  return goRouter;
}
*/
