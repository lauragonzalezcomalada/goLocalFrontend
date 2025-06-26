import 'package:flutter/material.dart';
//import 'package:worldwildprova/screens/second_screen.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  bool _showWelcome = true;

  /*void _onBackgroundTap() {
    setState(() {
      _showWelcome = false;
    });
  }

  void _onButtonTap() {
    setState(() {
      _showWelcome = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SecondScreen(
          placeUuid:
              '0cffbdd2-c0ce-4b6d-94a3-0bb7e2123c1f', // El UUID de la ubicación
          placeName: 'Buenos Aires', // El nombre del lugar
          fromMainScaffold: true,
        ),
      ),
    );
  }*/

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
