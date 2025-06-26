import 'package:worldwildprova/models_fromddbb/tag.dart';
import 'package:worldwildprova/models_fromddbb/tagChip.dart';
import 'package:worldwildprova/widgets/listableitem.dart';

class Promo extends ListableItem {
  final String uuid;
  final String name;
  final String? shortDesc;
  final String? desc;
  final String placeName;
  final String? activityImageUrl;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final List<Tag>? tags;
  final String? activityCreatorImageUrl;
  final int asistentes;
  final bool? created_by_user;
  final double? lat;
  final double? long;

  Promo(
      {required this.uuid,
      required this.name,
      this.shortDesc,
      this.desc,
      //required this.type,
      required this.placeName,
      this.activityImageUrl,
      required this.startDateTime,
      required this.endDateTime,
      this.tags,
      this.activityCreatorImageUrl,
      required this.asistentes,
      this.created_by_user, this.lat, this.long});

  // Método para convertir el JSON recibido en un objeto Activity para listar
  factory Promo.fromJson(Map<String, dynamic> json, bool fromUserProfile) {
   
    return Promo(
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
        startDateTime: DateTime.parse(json['startDateandtime']),
        endDateTime: DateTime.parse(json['endDateandtime']),
        tags: (json['tag_detail'] as List)
            .map((tagJson) =>
                Tag.fromJson(tagJson)) // Mapea cada tag a la clase Tag
            .toList(),
        asistentes: json['asistentes'],
        activityCreatorImageUrl:
            'http://192.168.0.17:8000' + json['creador_image'],
        created_by_user: json['created_by_user'],);
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
        activityImageUrl: json["image"] == null
            ? null
            : 'http://192.168.0.17:8000' + json["image"],
        startDateTime: DateTime.parse(json['startDateandtime']),
        endDateTime: DateTime.parse(json['endDateandtime']),
        tags: (json['tag_detail'] as List)
            .map((tagJson) =>
                Tag.fromJson(tagJson)) // Mapea cada tag a la clase Tag
            .toList(),
        asistentes: json['asistentes'],
        activityCreatorImageUrl:
            'http://192.168.0.17:8000' + json['creador_image'],
        created_by_user: json['created_by_user'],
        lat: json['lat'],
        long: json['long']);
  }
}
