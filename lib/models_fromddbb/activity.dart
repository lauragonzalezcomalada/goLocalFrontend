import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/asistentes.dart';
import 'package:worldwildprova/models_fromddbb/entrada.dart';
import 'package:worldwildprova/models_fromddbb/evento.dart';
import 'package:worldwildprova/models_fromddbb/reserva.dart';
import 'package:worldwildprova/models_fromddbb/tag.dart';
import 'package:worldwildprova/models_fromddbb/tagChip.dart';
import 'package:worldwildprova/widgets/listableitem.dart';

class Activity extends ListableItem implements Evento {
  @override
  final String uuid;
  @override
  final String name;
  @override
  final String? imageUrl;
  @override
  final DateTime dateTime;
  @override
  final bool? created_by_user;
  @override
  final bool? tiene_tickets;
  @override
  final bool? active;

  final String? shortDesc;
  final String? desc;
  final String? placeName;
  final List<Tag>? tags;
  final bool? gratis;
  final double? price;
  final String? activityCreatorImageUrl;
  late bool? going;
  final double? lat;
  final double? long;
  final bool? conReserva;
  final List<Usuario>? asistentes;
  final List<Entrada>? entradas;
  final List<Reserva>? reservas_forms;
  final String? tickets_link;
  final List<Usuario>? creadores;

  Activity(
      {required this.uuid,
      required this.name,
      this.shortDesc,
      this.desc,
      //required this.type,
      this.placeName,
      this.imageUrl,
      required this.dateTime,
      this.tags,
      this.gratis,
      this.activityCreatorImageUrl,
      this.asistentes,
      this.created_by_user,
      this.going,
      this.lat,
      this.long,
      this.price,
      this.conReserva,
      this.entradas,
      this.tiene_tickets,
      this.active,
      this.reservas_forms,
      this.tickets_link,
      this.creadores});

  // Método para convertir el JSON recibido en un objeto Activity para listar
  factory Activity.fromJson(Map<String, dynamic> json, bool fromUserProfile) {
    return Activity(
        uuid: json['uuid'],
        name: json['name'],
        shortDesc: json['shortDesc'],
        //  type: json["type"],
        placeName: json["place_name"],
        imageUrl: json["image"] == null ? null : json["image"],
        // : json["image"],
        dateTime: DateTime.parse(json['startDateandtime']),
        tags: json['tag_detail'] != null
            ? (json['tag_detail'] as List)
                .map((tagJson) => Tag.fromJson(tagJson))
                .toList()
            : [],
        gratis: json['gratis'],
        activityCreatorImageUrl: json['creador_image'] == null
            ? null
            : Config.serverIp + json['creador_image'],
        created_by_user: json['created_by_user'],
        tiene_tickets: json['tiene_ticket'],
        active: json['active']);
  }
  // Método para convertir el JSON recibido en un objeto Activity para dar los detalles
  factory Activity.fromServerJson(Map<String, dynamic> json) {
    print('json de una activity detail: $json');
    return Activity(
        uuid: json['uuid'],
        name: json['name'],
        shortDesc: json['shortDesc'],
        desc: json['desc'],
        //  type: json["type"],
        placeName: json["place_name"],
        imageUrl: json["image"],
        dateTime: DateTime.parse(json['startDateandtime']),
        tags: (json['tag_detail'] as List)
            .map((tagJson) =>
                Tag.fromJson(tagJson)) // Mapea cada tag a la clase Tag
            .toList(),
        gratis: json['gratis'],
        activityCreatorImageUrl: json['creador_image'] == null
            ? null
            : Config.serverIp + json['creador_image'],
        created_by_user: json['created_by_user'],
        going: json['user_isgoing'],
        lat: json['lat'],
        long: json['long'],
        price: json['price'],
        conReserva: json['reserva_necesaria'],
        asistentes: (json['asistentes'] as List)
            .map((asistenteJson) => Usuario.fromJson(asistenteJson))
            .toList(),
        entradas: (json['entradas_for_plan'] as List)
            .map((entradaJson) => Entrada.fromJson(entradaJson))
            .toList(),
        reservas_forms: (json['reservas_forms'] as List)
            .map((reservaFormJson) => Reserva.fromJson(reservaFormJson))
            .toList(),
        creadores: json['creadores'] != null
            ? (json['creadores'] as List)
                .map((usuarioJson) => Usuario.fromJson(usuarioJson))
                .toList()
            : null,
        tiene_tickets: json['tiene_ticket'],
        active: json['active'],
        tickets_link: json['tickets_link']);
  }
}
