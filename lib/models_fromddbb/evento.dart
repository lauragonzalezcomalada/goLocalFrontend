import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/models_fromddbb/privatePlan.dart';
import 'package:worldwildprova/models_fromddbb/promo.dart';

abstract class Evento {
  final String uuid;
  final String name;
  final String? imageUrl;
  final DateTime dateTime;
  final bool? created_by_user;
  final bool? tiene_tickets;

  Evento(
      {required this.uuid,
      required this.imageUrl,
      required this.name,
      required this.dateTime,
      required this.created_by_user,
      this.tiene_tickets});

  factory Evento.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'activity':
        return Activity.fromJson(json, true);
      case 'promo':
        return Promo.fromJson(json, true);
      case 'privateplan':
        return PrivatePlan.fromJson(json);
      default:
        throw Exception('Tipo de evento desconocido');
    }
  }
}
