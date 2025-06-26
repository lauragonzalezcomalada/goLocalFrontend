import 'package:flutter/material.dart';
import 'package:worldwildprova/models_fromddbb/place.dart';
import 'package:worldwildprova/screens/second_screen.dart';
import 'package:worldwildprova/widgets/placecard.dart';

import 'package:http/http.dart' as http;
import 'dart:convert'; // Necesario para convertir JSON a objetos


class PlaceCarousel extends StatefulWidget {
  const PlaceCarousel({super.key});


  @override
  _PlaceCarouselState createState() => _PlaceCarouselState();
}

class _PlaceCarouselState extends State<PlaceCarousel> {

  // Definir un PageController con viewportFraction para mostrar parte de la siguiente tarjeta
  final PageController _pageController = PageController(viewportFraction: 0.9);

  // toda la lógica, fetch, build, etc., va aquí
  @override
  void initState() {
    super.initState();
    fetchPlaces(); // Llamamos la función al iniciar
  }

  List<Place> places = [];

  // Función para hacer la solicitud GET
  Future<void> fetchPlaces() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.0.17:8000/api/places/'));
      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, convertimos el JSON a objetos
        List<dynamic> data = json.decode(response.body);
        setState(() {
          places = data.map((placeJson) => Place.fromJson(placeJson)).toList();
        });
      } else {
        // Si la respuesta es un error, muestra un mensaje
        throw Exception('Failed to load places');
      }
    } catch (e) {
      // Si ocurre un error en la solicitud
      print('Error: $e');
    }
  }


@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 20.0, left: 10.0, right:10.0, bottom: 10.0),
    child: PageView.builder(
      controller: _pageController, 
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];

        return GestureDetector(
          onTap: () {
            // Al presionar la tarjeta, navega a la segunda pantalla
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SecondScreen(
                  placeName: place.name,
                  placeUuid: place.uuid,
                  fromMainScaffold: false,
                ),
              ),
            );
          },
          child: PlaceCard(
            placeUuid: place.uuid,
            placeName: place.name,
            placeDescription: place.description,
            imageUrl: place.imageUrl!, // Concatenamos la URL base
          ),
        );
      },
      // Aquí ajustamos el `viewportFraction` para mostrar parcialmente la tarjeta siguiente
    ),
  );
}


}

