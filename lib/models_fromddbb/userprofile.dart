import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/models_fromddbb/evento.dart';
import 'package:worldwildprova/models_fromddbb/message.dart';
import 'package:worldwildprova/models_fromddbb/tag.dart';
import 'package:worldwildprova/models_fromddbb/tagChip.dart';

class UserProfile {
  final String uuid;
  final String username;
  final String? bio;
  final String? originLocation;
  final String? email;
  final String? userImageUrl;
  //final int rate;
  final List<Tag>? tags;
  // final List<Activity>? activities;
  final List<Evento>? eventos;
  final List<Evento>? eventosCreados;
  final bool? creador;
  final bool? canCreateFreePlan;
  final bool? canCreatePaymentPlan;
  final List<Message>? unreadMessages;

  UserProfile(
      {required this.uuid,
      required this.username,
      this.bio,
      this.originLocation,
      this.userImageUrl,
      this.email,
      //required this.rate,
      this.tags,
      this.eventos,
      this.creador,
      this.canCreateFreePlan,
      this.canCreatePaymentPlan,
      this.eventosCreados,
      this.unreadMessages});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    print('json del userprofile: $json');
    var a = UserProfile(
        uuid: json['uuid'],
        username: json['username'],
        bio: json['bio'],
        originLocation: json['originLocation'],
        userImageUrl: json['image'],
        email: json['email'],
        creador: json['creador'],
        canCreateFreePlan: json['can_create_free_plan'],
        canCreatePaymentPlan: json['can_create_payment_plan'],
        tags: json['tags'] != null
            ? (json['tags'] as List)
                .map((tagJson) => Tag.fromJson(tagJson))
                .toList()
            : [],
        eventos: json['eventos'] != null
            ? (json['eventos'] as List)
                .map((eventJson) => Evento.fromJson(eventJson))
                .toList()
            : [],
        eventosCreados: json['eventos_creados'] != null
            ? (json['eventos_creados'] as List)
                .map((eventJson) => Evento.fromJson(eventJson))
                .toList()
            : [],
        unreadMessages: json['unread_messages'] != null
            ? (json['unread_messages'] as List)
                .map((unreadMessageJson) => Message.fromJson(unreadMessageJson))
                .toList()
            : []);
    return a;
  }

  //For listing the userProfiles in the private plan option
  factory UserProfile.fromServerJson(Map<String, dynamic> json) {
    return UserProfile(uuid: json['uuid'], username: json['username']);
  }
}
