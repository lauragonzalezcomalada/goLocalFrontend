import 'package:worldwildprova/models_fromddbb/item.dart';
import 'package:worldwildprova/models_fromddbb/userprofile.dart';
import 'package:worldwildprova/widgets/listableitem.dart';

class PrivatePlan extends ListableItem {
  final String uuid;
  final String name;
  final String? shortDesc;
  final String? desc;
  final String? placeName;
  final double? lat;
  final double? long;
  final String? imageUrl;
  final bool? created_by_user;
  final bool? going;
  final bool? conReserva;
  final bool? gratis;
  final double? price;
  final String invitationCode;
  final List<UserProfile>? invitados;
  final DateTime dateTime;
  final List<Item>? items;

  PrivatePlan(
      {required this.uuid,
      required this.name,
      this.shortDesc,
      this.desc,
      this.placeName,
      this.lat,
      this.long,
      this.imageUrl,
      this.created_by_user,
      this.going,
      this.conReserva,
      this.gratis,
      this.price,
      required this.dateTime,
      required this.invitationCode,
      this.invitados,
      this.items
      /* this.invitados*/
      });

  factory PrivatePlan.fromJson(Map<String, dynamic> json) {
    var a = PrivatePlan(
      uuid: json['uuid'],
      name: json['name'],
      shortDesc: json['shortDesc'],
      desc: json['desc'],
      lat: json['lat'],
      long: json['long'],
      going: json['user_isgoing'],
      gratis: json['gratis'],
      price: json['price'],
      imageUrl: 'http://192.168.0.17:8000' +
          json[
              "image"] /*== null
          ? null
          : fromUserProfile == false
              ? 'http://192.168.0.17:8000' + json["image"]
              : json["image"]*/
      ,
      dateTime: DateTime.parse(json['startDateandtime']),
      invitationCode: json['invitation_code'],
      invitados: (json['invited_users'] != null)
          ? (json['invited_users'] as List)
              .map((invitadoJson) => UserProfile.fromServerJson(invitadoJson))
              .toList()
          : <UserProfile>[],
      items: (json['items'] as List).map((itemJson) => Item.fromJson(itemJson)).toList()
    );
    print(a);
    return a;
  }
}
