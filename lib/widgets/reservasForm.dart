import 'package:flutter/material.dart';
import 'package:worldwildprova/models_fromddbb/campo.dart';
import 'package:worldwildprova/models_fromddbb/reserva.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
import 'package:worldwildprova/widgets/camposForm.dart';

/// Widget hijo de reservas, recibe onGuardar para reportar la nueva reserva al form principal
class ReservasForm extends StatefulWidget {
  final Function(List<Reserva>) onReservasChanged; // Callback al form principal

  const ReservasForm({super.key, required this.onReservasChanged});

  @override
  State<ReservasForm> createState() => _ReservasFormState();
}

class _ReservasFormState extends State<ReservasForm> {
  List<Reserva> reservas = [];
  bool mostrarFormulario = false;

  final TextEditingController tipoReservaController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  List<Campo> camposAgregados = [];

  void agregarCampo(Campo campo) {
    setState(() {
      camposAgregados.add(campo);
    });
  }

  void guardar() {
    final tipo = tipoReservaController.text;
    final cantidad = int.tryParse(cantidadController.text);

    if (tipo.isEmpty || cantidad == null || camposAgregados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Completá todos los campos y agregá al menos un campo')),
      );
      return;
    }

    setState(() {
      reservas.add(Reserva(
          tipoReserva: tipo,
          cantidad: cantidad,
          campos: List.from(camposAgregados)));
    });
    tipoReservaController.clear();
    cantidadController.clear();
    camposAgregados.clear();

    widget.onReservasChanged(reservas);

    tipoReservaController.clear();
    cantidadController.clear();
    camposAgregados.clear();
    setState(() {
      mostrarFormulario = false;
    });
  }

  void cancelar() {
    tipoReservaController.clear();
    cantidadController.clear();
    camposAgregados.clear();
    setState(() {
      mostrarFormulario = false;
    });
  }

  void deleteReserva(int index) {
    setState(() {
      reservas.removeAt(index);
    });
    widget.onReservasChanged(reservas);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...reservas.asMap().entries.map(
          (entry) {
            int index = entry.key;
            Reserva reserva = entry.value;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.naranja_light,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              deleteReserva(index), // llama a tu método
                          child: const Icon(
                            Icons.close,
                            size: 22,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lado izquierdo: tipoReserva y cantidad
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reserva.tipoReserva,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 30)),
                            Text('Cantidad: ${reserva.cantidad}',
                                style: const TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16), // separación entre columnas
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: reserva.campos
                              .map((c) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 2), // espacio entre campos
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.logo,
                                      border: Border.all(
                                        color: AppTheme.logo, // color del borde
                                        width: 2, // grosor del borde
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      ' ${c.label}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontSize: 18),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ).toList(),
        if (!mostrarFormulario)
          GestureDetector(
            onTap: () => setState(() => mostrarFormulario = true),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                children: const [
                  Icon(Icons.add, size: 30),
                  Text('Crear nueva formulario de reserva',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        if (mostrarFormulario)
          Card(
            color: Colors.grey[200],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: tipoReservaController,
                    decoration:
                        const InputDecoration(labelText: 'Tipo de reserva'),
                  ),
                  TextField(
                    controller: cantidadController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                  ),
                  const SizedBox(height: 12),
                  ...camposAgregados
                      .map((c) => Text(c.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppTheme.logo)))
                      .toList(),
                  SizedBox(height: 12),
                  CamposForm(
                    // camposAgregados: camposAgregados,
                    onAgregar: agregarCampo,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: guardar,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.naranja_light),
                        child: const Text('Aceptar',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 20)),
                      ),
                      ElevatedButton(
                        onPressed: cancelar,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                        child: const Text('Cancelar',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 20)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
