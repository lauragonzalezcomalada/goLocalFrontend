import 'package:flutter/material.dart';
import 'package:worldwildprova/screens/create_plan_screen.dart';
import 'package:worldwildprova/screens/onboarding_screen.dart';
import 'package:worldwildprova/screens/log_in_screen.dart';
import 'package:worldwildprova/screens/placecarousel_screen.dart';
import 'package:worldwildprova/screens/second_screen.dart';
import 'package:worldwildprova/widgets/eventcard.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;
  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex = 0;

  final List<Widget> _screens = [
    /*const ActivityCard(activityTitle: 'Actividad prueba',), */ // index 0
    const SecondScreen(
      placeUuid:
          '0cffbdd2-c0ce-4b6d-94a3-0bb7e2123c1f', // El UUID de la ubicación
      placeName: 'Buenos Aires', // El nombre del lugar
      fromMainScaffold: true,
    ),
    const CreatePlanScreen(), // index 1
    LogInScreen(
      comingFromOnboarding: false,
    ), // index 2
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Aquí va tu página actual
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
        }),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.brush), label: 'Crear plan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
