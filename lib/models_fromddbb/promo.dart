import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/evento.dart';
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

  final String? shortDesc;
  final String? desc;
  final String placeName;
  final DateTime endDateTime;
  final List<Tag>? tags;
  final String? activityCreatorImageUrl;
  final int asistentes;
  final double? lat;
  final double? long;

  Promo(
      {required this.uuid,
      required this.name,
      this.shortDesc,
      this.desc,
      //required this.type,
      required this.placeName,
      this.imageUrl,
      required this.dateTime,
      required this.endDateTime,
      this.tags,
      this.activityCreatorImageUrl,
      required this.asistentes,
      this.created_by_user,
      this.lat,
      this.long,
      this.tiene_tickets});

  // Método para convertir el JSON recibido en un objeto Activity para listar
  factory Promo.fromJson(Map<String, dynamic> json, bool fromUserProfile) {
    return Promo(
      uuid: json['uuid'],
      name: json['name'],
      shortDesc: json['shortDesc'],
      //  type: json["type"],
      placeName: json["place_name"],
      imageUrl: json["image"] == null
          ? null
          : fromUserProfile == false
              ? Config.serverIp + json["image"]
              : json["image"],
      dateTime: DateTime.parse(json['startDateandtime']),
      endDateTime: DateTime.parse(json['endDateandtime']),
      tags: (json['tag_detail'] as List)
          .map((tagJson) =>
              Tag.fromJson(tagJson)) // Mapea cada tag a la clase Tag
          .toList(),
      asistentes: json['asistentes'],
      activityCreatorImageUrl: Config.serverIp + json['creador_image'],
      created_by_user: json['created_by_user'],
      tiene_tickets: json['tiene_ticket'],
    );
  }
  // Método para convertir el JSON recibido en un objeto Activity para dar los detalles
  factory Promo.fromServerJson(Map<String, dynamic> json) {
    return Promo(
        uuid: json['uuid'],
        name: json['name'],
        shortDesc: json['shortDesc'],
        desc: json['desc'],
        //  type: json["type"],
        placeName: json["place_name"],
        imageUrl:
            json["image"] == null ? null : Config.serverIp + json["image"],
        dateTime: DateTime.parse(json['startDateandtime']),
        endDateTime: DateTime.parse(json['endDateandtime']),
        tags: (json['tag_detail'] as List)
            .map((tagJson) =>
                Tag.fromJson(tagJson)) // Mapea cada tag a la clase Tag
            .toList(),
        asistentes: json['asistentes'],
        activityCreatorImageUrl: Config.serverIp + json['creador_image'],
        created_by_user: json['created_by_user'],
        lat: json['lat'],
        long: json['long'],
        tiene_tickets: json['tiene_ticket']);
  }
}
