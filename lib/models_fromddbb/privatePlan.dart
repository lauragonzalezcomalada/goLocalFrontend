import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/evento.dart';
import 'package:worldwildprova/models_fromddbb/item.dart';
import 'package:worldwildprova/models_fromddbb/userprofile.dart';
import 'package:worldwildprova/widgets/listableitem.dart';

class PrivatePlan extends ListableItem implements Evento {
  @override
  final String uuid;
  @override
  final String name;
  @override
  final String? imageUrl;
  @override
  final DateTime dateTime;
  @override
  // ignore: non_constant_identifier_names
  final bool? created_by_user;
  @override
  final bool? tiene_tickets;
  @override
  final bool? active;

  final String? shortDesc;
  final String? desc;
  final String? placeName;
  final double? lat;
  final double? long;
  final String? direccion;
  final bool? going;
  final bool? conReserva;
  final bool? gratis;
  final double? price;
  final String? invitationCode;
  final List<UserProfile>? invitados;
  final List<Item>? items;
  bool? userIsGoing;

  PrivatePlan(
      {required this.uuid,
      required this.name,
      this.shortDesc,
      this.desc,
      this.placeName,
      this.lat,
      this.long,
      this.direccion,
      this.imageUrl,
      this.created_by_user,
      this.going,
      this.conReserva,
      this.gratis,
      this.price,
      required this.dateTime,
      this.invitationCode,
      this.invitados,
      this.items,
      this.userIsGoing,
      this.tiene_tickets,
      this.active});

  factory PrivatePlan.fromJson(Map<String, dynamic> json) {
    var a = PrivatePlan(
        uuid: json['uuid'],
        name: json['name'],
        shortDesc: json['shortDesc'],
        desc: json['desc'],
        lat: json['lat'],
        long: json['long'],
        direccion: json['direccion'],
        going: json['user_isgoing'],
        gratis: json['gratis'],
        price: json['price'],
        imageUrl: json["image"],
        dateTime: DateTime.parse(json['startDateandtime']).toLocal(),
        invitationCode: json['invitation_code'] != null
            ? 'golocal://privateplaninvitation/' + json['invitation_code']
            : '',
        invitados: (json['invited_users'] != null)
            ? (json['invited_users'] as List)
                .map((invitadoJson) => UserProfile.fromServerJson(invitadoJson))
                .toList()
            : <UserProfile>[],
        items: json['items'] != null
            ? (json['items'] as List)
                .map((itemJson) => Item.fromJson(itemJson))
                .toList()
            : [],
        userIsGoing: json['user_is_invited'],
        tiene_tickets: json['tiene_ticket'],
        active: json['active']);
    return a;
  }
}
