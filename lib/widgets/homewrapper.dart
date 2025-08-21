import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/screens/log_in_screen.dart';
import 'package:worldwildprova/screens/profile_screen.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/privatePlanDetail.dart';

class HomeWrapper extends StatefulWidget {
  final Uri? initialDeepLink;
  const HomeWrapper({super.key, this.initialDeepLink});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  bool _linkHandled = false; // para evitar manejar el mismo link varias veces
  bool _showWelcome = true;
  Uri? _lastHandledUri;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialDeepLink != null) {
        _handleDeepLink(widget.initialDeepLink!);
      }
    });
  }

  @override
  void didUpdateWidget(covariant HomeWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newUri = widget.initialDeepLink;
    if (newUri != null && newUri != _lastHandledUri) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleDeepLink(newUri);
      });
    }
  }

  void _handleDeepLink(Uri uri) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    bool isLoggedIn = await authService.isLoggedIn();
    final path = uri.host;
    //  final segments = uri.pathSegments;
    print('HANDLE DEEP LINK PATH: $path');
    if (uri.host == 'privateplaninvitation' && uri.pathSegments.isNotEmpty) {
      if (isLoggedIn == false) {
        // Si el usuario no está logueado, redirigir a la pantalla de login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LogInScreen(comingFromOnboarding: false),
          ),
        );
        return;
      }
      final planUuid = uri.pathSegments[0];
      final userToken = await authService.getAccessToken();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PrivatePlanDetail(
              privatePlanUuid: planUuid, userToken: userToken!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MainScaffold(), // Pantalla principal con navegación
        if (_showWelcome)
          GestureDetector(
              child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showWelcome = false;
                        });
                      },
                      child: Image.asset(
                        'assets/boton_sol.png',
                        width: 300,
                        height: 300,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ))),
      ],
    );
  }
}
