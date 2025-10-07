import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapaDesdeBackend extends StatefulWidget {
  final double lat;
  final double long;
  final String direccion;

  const MapaDesdeBackend(
      {required this.lat,
      required this.long,
      required this.direccion,
      super.key});

  @override
  State<MapaDesdeBackend> createState() => _MapaDesdeBackendState();
}

class _MapaDesdeBackendState extends State<MapaDesdeBackend> {
  Future<void> _abrirEnMaps() async {
    final lat = widget.lat;
    final long = widget.long;

    // URL universal que abre en la app de mapas predeterminada
    final Uri url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$long');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la app de mapas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng ubicacion = LatLng(widget.lat, widget.long);

    final partes = widget.direccion.split(',');
    final direccionCorta = partes.sublist(0, partes.length - 1).join(',');

    return Column(
      children: [
        SizedBox(
          height: 100,
          width: double.infinity,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: ubicacion,
              zoom: 14,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('lugar_marker'),
                position: LatLng(widget.lat, widget.long),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange),
                infoWindow: const InfoWindow(
                  title: 'Lugar',
                  snippet: 'Aquí está el marcador',
                ),
              ),
            },
          ),
        ),
        TextButton.icon(
          onPressed: _abrirEnMaps,
          //  icon: const Icon(Icons.map),
          label: Text(direccionCorta,
              softWrap: true,
              style: TextStyle(
                  fontWeight: FontWeight.w600, height: 0.5, fontSize: 15)),
        )
      ],
    );
  }
}
