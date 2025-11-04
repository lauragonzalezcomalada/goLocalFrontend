import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/models_fromddbb/campo.dart';
import 'package:worldwildprova/models_fromddbb/reserva.dart';
import 'package:worldwildprova/models_fromddbb/userprofile.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
import 'package:worldwildprova/widgets/authservice.dart';

class CreateReservaBottomSheet extends StatefulWidget {
  final List<Reserva> reservas_forms;
  final void Function(Map<String, dynamic>) onConfirm;

  CreateReservaBottomSheet({
    super.key,
    required this.reservas_forms,
    required this.onConfirm,
  });

  @override
  State<CreateReservaBottomSheet> createState() =>
      _CreateReservaBottomSheetState();
}

class _CreateReservaBottomSheetState extends State<CreateReservaBottomSheet> {
  String? tipoReservaSeleccionado;
  List<Campo> camposActuales = [];

  // Map para guardar los controllers dinámicamente
  Map<String, TextEditingController> controllers = {};
  @override
  void dispose() {
    // Liberar todos los controllers
    controllers.forEach((key, ctrl) => ctrl.dispose());
    super.dispose();
  }

  void actualizarCampos(String? tipoReserva) {
    if (tipoReserva == null) return;

    final reserva =
        widget.reservas_forms.firstWhere((r) => r.tipoReserva == tipoReserva);

    // Crear controllers nuevos para cada campo
    Map<String, TextEditingController> nuevosControllers = {};
    for (var campo in reserva.campos) {
      // si ya existe un controller para ese nombre, lo reutiliza
      nuevosControllers[campo.label] =
          controllers[campo.label] ?? TextEditingController();
    }

    setState(() {
      tipoReservaSeleccionado = tipoReserva;
      camposActuales = reserva.campos;
      controllers = nuevosControllers;
    });
  }

  void handleReservar() {
    if (tipoReservaSeleccionado == null) return;
    final reservaSeleccionada = widget.reservas_forms
        .firstWhere((r) => r.tipoReserva == tipoReservaSeleccionado);

    final Map<String, String> valoresCampos = {};
    camposActuales.forEach((campo) {
      valoresCampos[campo.nombre!] = controllers[campo.label]?.text ?? '';
    });
    // Armamos el objeto final con uuid y campos
    final resultado = {
      'reserva_uuid': reservaSeleccionada.uuid,
      'valores': valoresCampos,
    };

    // Enviamos al widget padre
    widget.onConfirm(resultado);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.9,
          child: SingleChildScrollView(
            controller: scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'HACÉ TU RESERVA',
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.logo),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(height: 20),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            border: BoxBorder.all(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          width: 300,
                          height: 80,
                          child: Center(
                            child: DropdownButton<String>(
                                hint: Text(
                                  'Selecciona una opción',
                                  style: TextStyle(fontSize: 20),
                                ),
                                value:
                                    tipoReservaSeleccionado, // valor seleccionado
                                items: widget.reservas_forms.map((opcion) {
                                  return DropdownMenuItem<String>(
                                    value: opcion.tipoReserva,
                                    child: Text(
                                      opcion.tipoReserva,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                  );
                                }).toList(),
                                onChanged: actualizarCampos),
                          ),
                        ),
                        SizedBox(
                            height:
                                50), // Generar TextFormField dinámicamente según los campos
                        ...camposActuales.map((campo) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              controller: controllers[campo.label],
                              keyboardType: campo.type == 'number'
                                  ? TextInputType.number
                                  : TextInputType.text,
                              decoration: InputDecoration(
                                hintText: campo.label,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                filled: true,
                                fillColor: Colors.white70,
                              ),
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 20),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                      ),
                      onPressed: handleReservar,
                      child: const Text(
                        'Confirmar reserva',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
