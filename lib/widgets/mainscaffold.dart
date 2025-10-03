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

  late final List<Widget> _screens;

  /*final List<Widget> _screens = [
    /*const ActivityCard(activityTitle: 'Actividad prueba',), */ // index 0
    const SecondScreen(
      placeUuid:
          '3aa3b0c6-e22a-4872-bb5e-ad47ae89d468', // El UUID de la ubicación
      placeName: 'Buenos Aires', // El nombre del lugar
      fromMainScaffold: true,
    ),
    const CreatePlanScreen(), // index 1
    LogInScreen(
      comingFromOnboarding: false,
    ), // index 2
  ];*/

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      const SecondScreen(
        placeUuid: '3aa3b0c6-e22a-4872-bb5e-ad47ae89d468',
        placeName: 'Buenos Aires',
        fromMainScaffold: true,
      ),
      const CreatePlanScreen(),
      LogInScreen(comingFromOnboarding: false),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 👇 IndexedStack mantiene el estado de cada pantalla
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _currentIndex == 0 ? _screens[0] : Container(),
          _currentIndex == 1 ? _screens[1] : Container(),
          _currentIndex == 2 ? _screens[2] : Container(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
        }),
        items: [
          BottomNavigationBarItem(
              icon: Image.asset(
                'assets/explorar.png',
                height: 30, // ajustá el tamaño
                width: 30,
              ),
              label: 'Explorar'),
          BottomNavigationBarItem(
              icon: Image.asset(
                'assets/pincel3.png',
                height: 30, // ajustá el tamaño
                width: 30,
              ),
              label: 'Crear Plan'),
          BottomNavigationBarItem(
              icon: Image.asset(
                'assets/solocarita.png',
                height: 30, // ajustá el tamaño
                width: 30,
              ),
              label: 'Perfil'),
        ],
      ),
    );
  }
}
