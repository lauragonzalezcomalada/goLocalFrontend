import 'package:worldwildprova/models_fromddbb/campo.dart';

class Reserva {
  String? uuid;
  String tipoReserva;
  int cantidad;
  List<Campo> campos;

  Reserva(
      {this.uuid,
      required this.tipoReserva,
      required this.cantidad,
      required this.campos});

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      uuid: json['uuid'],
      // intenta 'tipoReserva', si no existe usa 'nombre', si tampoco existe, ''
      tipoReserva: json['tipoReserva'] ?? json['nombre'] ?? '',

      // intenta 'cantidad', si no existe usa 'max_disponibilidad', si tampoco existe, 0
      cantidad: json['cantidad'] ?? json['max_disponibilidad'] ?? 0,

      // campos, si es null o vacío, usa lista vacía
      campos: (json['campos'] as List<dynamic>? ?? [])
          .map((campoJson) => Campo.fromJson(campoJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipoReserva': tipoReserva,
      'cantidad': cantidad,
      'campos': campos.map((c) => c.toJson()).toList(),
    };
  }
}
