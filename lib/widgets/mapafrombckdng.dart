import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaDesdeBackend extends StatefulWidget {
  final double lat;
  final double long;
  final String? imageUrl;

  const MapaDesdeBackend(
      {required this.lat,
      required this.long,
      this.imageUrl,
      super.key});

  @override
  State<MapaDesdeBackend> createState() => _MapaDesdeBackendState();
}

class _MapaDesdeBackendState extends State<MapaDesdeBackend> {
  //final Set<Marker> _markers = {};
  /*BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    customMarker();
  }

  void customMarker() async {
    final icon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(5, 5)),
      "assets/boton_sol.png",
    );

    setState(() {
      customIcon = icon;
      _markers.add(
       
    });
    print(_markers);
  }*/

  @override
  Widget build(BuildContext context) {
    final LatLng ubicacion = LatLng(widget.lat, widget.long);

    return SizedBox(
      height: 100, // altura fija
      width: double.infinity,

      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: ubicacion,
          zoom: 14,
        ),
        markers: { Marker(
          markerId: const MarkerId('lugar_marker'),
          position: LatLng(widget.lat, widget.long),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(
            title: 'Lugar',
            snippet: 'Aquí está el marcador',
          ),
        ),
      },
      ),
    );
  }
}
