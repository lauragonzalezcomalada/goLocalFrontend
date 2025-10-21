import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/asistentes.dart';
import 'package:worldwildprova/models_fromddbb/evento.dart';
import 'package:worldwildprova/models_fromddbb/reserva.dart';
import 'package:worldwildprova/models_fromddbb/tag.dart';
import 'package:worldwildprova/models_fromddbb/tagChip.dart';
import 'package:worldwildprova/widgets/listableitem.dart';

class Promo extends ListableItem implements Evento {
  @override
  final String uuid;
  @override
  final String name;
  @override
  final DateTime dateTime;
  @override
  final bool? created_by_user;
  @override
  final String? imageUrl;
  @override
  final bool? tiene_tickets;
  @override
  final bool? active;
  late bool? going;
  final bool? conReserva;
  final String? shortDesc;
  final String? desc;
  final String placeName;
  final DateTime endDateTime;
  final List<Tag>? tags;
  final String? activityCreatorImageUrl;
  final List<Usuario>? asistentes;
  final double? lat;
  final double? long;
  final String? direccion;
  final List<Reserva>? reservas_forms;

  Promo(
      {required this.uuid,
      required this.name,
      this.shortDesc,
      this.desc,
      this.going,
      required this.placeName,
      this.imageUrl,
      required this.dateTime,
      required this.endDateTime,
      this.tags,
      this.activityCreatorImageUrl,
      this.asistentes,
      this.created_by_user,
      this.lat,
      this.long,
      this.direccion,
      this.conReserva,
      this.tiene_tickets,
      this.active,
      this.reservas_forms});

  // FOR LISTING
  factory Promo.fromJson(Map<String, dynamic> json, bool fromUserProfile) {
    List<Tag>? tagsList;
    if (json['tag_detail'] != null) {
      tagsList = (json['tag_detail'] as List)
          .map((tagJson) => Tag.fromJson(tagJson))
          .toList();
    }

    DateTime dateTime = json['startDateandtime'] != null
        ? DateTime.parse(json['startDateandtime']).toLocal()
        : DateTime.now();

    DateTime endDateTime = json['endDateandtime'] != null
        ? DateTime.parse(json['endDateandtime']).toLocal()
        : dateTime.add(Duration(hours: 1)); // fallback si no hay endDate

    return Promo(
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      shortDesc: json['shortDesc'],
      placeName: json["place"] ?? '',
      imageUrl: json['image'],
      dateTime: dateTime,
      endDateTime: endDateTime,
      tags: tagsList,
      activityCreatorImageUrl: json['creador_image'],
      created_by_user: json['created_by_user'] ?? false,
      tiene_tickets: json['tiene_ticket'] ?? false,
      active: json['active'] ?? false,
      lat: json['lat']?.toDouble(),
      long: json['long']?.toDouble(),
    );
  }

  // Método para convertir el JSON recibido en un objeto Promo para dar los detalles
  factory Promo.fromServerJson(Map<String, dynamic> json) {
    // Manejar tags
    List<Tag> tagsList = [];
    if (json['tag_detail'] != null) {
      tagsList = (json['tag_detail'] as List)
          .map((tagJson) => Tag.fromJson(tagJson))
          .toList();
    }

    // Manejar creador_image
    String? creatorImage;
    if (json['creador_image'] != null) {
      creatorImage = Config.serverIp + json['creador_image'];
    }

    return Promo(
      uuid: json['uuid'],
      name: json['name'],
      shortDesc: json['shortDesc'],
      desc: json['desc'],
      placeName: json['place'] ?? '',
      going: json['user_isgoing'],
      imageUrl: json['image'],
      dateTime: DateTime.parse(json['startDateandtime']).toLocal(),
      endDateTime: DateTime.parse(json['endDateandtime']).toLocal(),
      tags: tagsList,
      asistentes: json['asistentes'] != null
          ? (json['asistentes'] as List)
              .map((asistenteJson) => Usuario.fromJson(asistenteJson))
              .toList()
          : null,
      activityCreatorImageUrl: creatorImage,
      created_by_user: json['created_by_user'] ?? false,
      lat: json['lat'],
      long: json['long'],
      direccion: json['direccion'],
      tiene_tickets: json['tiene_ticket'] ?? false,
      active: json['active'],
      conReserva: json['reserva_necesaria'],
      reservas_forms: (json['reservas_forms'] as List)
          .map((reservaFormJson) => Reserva.fromJson(reservaFormJson))
          .toList(),
    );
  }
}
