import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/campo.dart';

// Widget que reemplaza a CamposForm de React
class CamposForm extends StatefulWidget {
  final Function(Campo) onAgregar;

  const CamposForm({super.key, required this.onAgregar});

  @override
  State<CamposForm> createState() => _CamposFormState();
}

class _CamposFormState extends State<CamposForm> {
  List<Campo> camposDisponibles = [];
  Campo? campoSeleccionado;

  @override
  void initState() {
    super.initState();
    fetchCampos();
  }

  Future<void> fetchCampos() async {
    try {
      final response =
          await http.get(Uri.parse(Config.serverIp + '/campos_reserva/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          camposDisponibles = data.map((c) => Campo.fromJson(c)).toList();
        });
      } else {
        print('Error al traer campos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void agregarCampo() {
    if (campoSeleccionado != null) {
      widget.onAgregar(campoSeleccionado!);
      setState(() {
        campoSeleccionado = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seleccioná un campo antes de añadir')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<Campo>(
          value: campoSeleccionado,
          hint: Text('Seleccionar campo...'),
          items: camposDisponibles
              .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
              .toList(),
          onChanged: (c) => setState(() => campoSeleccionado = c),
        ),
        SizedBox(height: 5),
        ElevatedButton(onPressed: agregarCampo, child: Text('Añadir campo')),
      ],
    );
  }
}
