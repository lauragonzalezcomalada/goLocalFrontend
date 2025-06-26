import 'package:worldwildprova/models_fromddbb/asistentes.dart';
import 'package:worldwildprova/models_fromddbb/tag.dart';
import 'package:worldwildprova/models_fromddbb/tagChip.dart';
import 'package:worldwildprova/widgets/listableitem.dart';

class Activity extends ListableItem {
  final String uuid;
  final String name;
  final String? shortDesc;
  final String? desc;
  //final int type;
  final String? placeName;
  final String? activityImageUrl;
  final DateTime dateTime;
  final List<Tag>? tags;
  final bool gratis;
  final double? price;
  final String? activityCreatorImageUrl;
  final bool? created_by_user;
  final bool? going;
  final double? lat;
  final double? long;
  final bool? conReserva;
  final List<Asistente>? asistentes;

  Activity(
      {required this.uuid,
      required this.name,
      this.shortDesc,
      this.desc,
      //required this.type,
      this.placeName,
      this.activityImageUrl,
      required this.dateTime,
      this.tags,
      required this.gratis,
      this.activityCreatorImageUrl,
      this.asistentes,
      this.created_by_user,
      this.going,
      this.lat,
      this.long,
      this.price,
      this.conReserva});

  // Método para convertir el JSON recibido en un objeto Activity para listar
  factory Activity.fromJson(Map<String, dynamic> json, bool fromUserProfile) {
    print(json);
    return Activity(
      uuid: json['uuid'],
      name: json['name'],
      shortDesc: json['shortDesc'],
      //  type: json["type"],
      placeName: json["place_name"],
      activityImageUrl: json["image"] == null
          ? null
          : fromUserProfile == false
              ? 'http://192.168.0.17:8000' + json["image"]
              : json["image"],
      dateTime: DateTime.parse(json['startDateandtime']),
      tags: (json['tag_detail'] as List)
          .map((tagJson) =>
              Tag.fromJson(tagJson)) // Mapea cada tag a la clase Tag
          .toList(),
      gratis: json['gratis'],
      activityCreatorImageUrl: json['creador_image'] == null
          ? null
          : 'http://192.168.0.17:8000' + json['creador_image'],
      created_by_user: json['created_by_user'],
    );
  }
  // Método para convertir el JSON recibido en un objeto Activity para dar los detalles
  factory Activity.fromServerJson(Map<String, dynamic> json) {
    return Activity(
        uuid: json['uuid'],
        name: json['name'],
        shortDesc: json['shortDesc'],
        desc: json['desc'],
        //  type: json["type"],
        placeName: json["place_name"],
        activityImageUrl: json["image"] == null ? null : json["image"],
        dateTime: DateTime.parse(json['startDateandtime']),
        tags: (json['tag_detail'] as List)
            .map((tagJson) =>
                Tag.fromJson(tagJson)) // Mapea cada tag a la clase Tag
            .toList(),
        gratis: json['gratis'],
        activityCreatorImageUrl:
            'http://192.168.0.17:8000' + json['creador_image'],
        created_by_user: json['created_by_user'],
        going: json['user_isgoing'],
        lat: json['lat'],
        long: json['long'],
        price: json['price'],
        conReserva: json['reserva_necesaria'],
        asistentes: (json['asistentes'] as List)
            .map((asistenteJson) => Asistente.fromJson(asistenteJson))
            .toList());
  }
}
