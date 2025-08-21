import 'package:flutter/widgets.dart';

class Entrada {
  final String uuid;
  final String titulo;
  final String? desc;
  final double precio;
  final int disponibles;

  Entrada(
      {required this.uuid,
      required this.titulo,
      this.desc,
      required this.precio,
      required this.disponibles});

  factory Entrada.fromJson(Map<String, dynamic> json) {
    return Entrada(
      uuid: json['uuid'],
      titulo: json['titulo'],
      desc: json['desc'],
      disponibles: json['disponibles'],
      precio: json['precio'],
    );
  }
}
