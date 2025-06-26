import 'package:flutter/material.dart';
import 'package:worldwildprova/screens/second_screen.dart';

class PlaceCard extends StatelessWidget {
  final String placeUuid;
  final String placeName;
  final String placeDescription;
  final String imageUrl;

  const PlaceCard({super.key, 
    required this.placeUuid,
    required this.placeName,
    required this.placeDescription,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Bordes redondeados
      ),
      elevation: 5, // Sombra para la tarjeta
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15), // Bordes redondeados
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.5,
                ),
                Positioned(
                    bottom: 5,
                    right: 8,
                    child: Text(
                      placeName,
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70),
                    ))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5), // da espacio entre elementos
                  SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.8, // o usa MediaQuery.of(context).size.width * 0.8
                    child: Text(
                      placeDescription,
                      style: const TextStyle(fontSize: 16),
                      softWrap: true,
                    ),
                  )
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SecondScreen(
                              placeUuid: placeUuid,
                              placeName: placeName
                              ,fromMainScaffold: false,
                            )));
              },
              child: const Text('Ver detalles'),
            )
          ],
        ),
      ),
    );
  }
}
