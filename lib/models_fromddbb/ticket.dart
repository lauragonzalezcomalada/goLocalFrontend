import 'package:flutter/material.dart';
import 'package:worldwildprova/config.dart';

class Ticket {
  String eventName;
  double precio;
  String compradorName;
  String compradorEmail;
  String qrUrl;
  DateTime eventStartDateTime;
  String? eventImageUrl;

  Ticket(
      {required this.eventName,
      required this.precio,
      required this.compradorEmail,
      required this.compradorName,
      required this.qrUrl,
      required this.eventStartDateTime,
      this.eventImageUrl});

  factory Ticket.fromServerJson(Map<String, dynamic> json) {
    Ticket t = Ticket(
        eventName: json['entrada']['activity_name'],
        precio: json['entrada']['precio'],
        compradorName: json['nombre'],
        compradorEmail: json['email'],
        qrUrl: /*Config.serverIp + */ json['qr_code'],
        eventStartDateTime: DateTime.parse(json['entrada']['activity_start']),
        eventImageUrl: json['entrada']['activity_image']);
    return t;
  }
}
