import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:worldwildprova/widgets/date_input_formatter.dart';
import 'package:worldwildprova/widgets/text_form_field_customized.dart';

// ignore: must_be_immutable
class FirstStep extends StatefulWidget {
  late TextEditingController birthdayController;
  late TextEditingController placeController;
  late String? selectedPlaceId;
  final void Function(String) onPlaceSelected;

  FirstStep({
    super.key,
    required this.birthdayController,
    required this.placeController,
    this.selectedPlaceId,
    required this.onPlaceSelected,
  });

  @override
  State<FirstStep> createState() => _FirstStepState();
}

class _FirstStepState extends State<FirstStep> {
  final GlobalKey<FormFieldState> _birthdayFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _locationFieldKey =
      GlobalKey<FormFieldState>();
  final FocusNode _focusBirthdayNode = FocusNode();
  final FocusNode _focusLocationNode = FocusNode();

  final String googleApiKey = 'AIzaSyBM51UAqo5azY443B3CxM8VMv-IIRLIOR0';

  // Per al camp de ubicació
  List<Map<String, dynamic>> _suggestions = [];

  // para el campo de la dirección:

  //Obtener sugerencias desde Places Autocomplete
  Future<void> _getPlaceSuggestions(String input) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _suggestions = (data['predictions'] as List)
            .map((item) => {
                  'description': item['description'],
                  'place_id': item['place_id'],
                })
            .toList();
      });
    } else {
      print("Autocomplete error: ${response.body}");
    }
  }

  Future<String?> _getPlaceDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_address&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      final direction = data['result']['formatted_address'];
      return direction;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.8,
        ), // Ancho máximo
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Bordes redondeados
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormFieldCustomized(
              controller: widget.birthdayController,
              fieldKey: _birthdayFieldKey,
              focusNode: _focusBirthdayNode,
              labelText: 'Fecha de nacimiento',
              hintText: 'dd/mm/yyyy',
              inputFormatters: [DateInputFormatter()],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Campo obligatorio';
                try {
                  final date = DateFormat('dd/MM/yyyy').parseStrict(value);
                  return null;
                } catch (_) {
                  return 'Formato inválido (dd/mm/yyyy)';
                }
              },
            ),
            SizedBox(height: 20),
            TextFormFieldCustomized(
              controller: widget.placeController,
              fieldKey: _locationFieldKey,
              focusNode: _focusLocationNode,
              labelText: 'Lugar',
              hintText: '',
              validator: (value) => widget.selectedPlaceId == null
                  ? 'Elegí un lugar válido'
                  : null,
              onChanged: (value) {
                _getPlaceSuggestions(value);
              },
            ),

            // ✅ Lista desplegable de sugerencias
            ..._suggestions.map((s) => ListTile(
                  title: Text(s['description']!),
                  onTap: () {
                    widget.placeController.text = s['description']!;
                    widget.onPlaceSelected(s['place_id']);
                    _suggestions = [];
                    setState(() {});
                  },
                )),
          ],
        ),
      ),
    );
  }
}
