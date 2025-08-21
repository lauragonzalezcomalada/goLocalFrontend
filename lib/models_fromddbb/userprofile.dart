import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/models_fromddbb/evento.dart';
import 'package:worldwildprova/models_fromddbb/tag.dart';
import 'package:worldwildprova/models_fromddbb/tagChip.dart';

class UserProfile {
  final String uuid;
  final String username;
  final String? bio;
  final String? originLocation;
  final String? userImageUrl;
  //final int rate;
  final List<Tag>? tags;
  // final List<Activity>? activities;
  final List<Evento>? eventos;
  UserProfile(
      {required this.uuid,
      required this.username,
      this.bio,
      this.originLocation,
      this.userImageUrl,
      //required this.rate,
      this.tags,
      this.eventos});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    var a = UserProfile(
        uuid: json['uuid'],
        username: json['username'],
        bio: json['bio'],
        originLocation: json['originLocation'],
        userImageUrl: json['image'],
        tags: (json['tags'] as List)
            .map((tagJson) =>
                Tag.fromJson(tagJson)) // Mapea cada tag a la clase Tag
            .toList(),
        eventos: (json['eventos'] as List)
            .map((eventJson) =>
                Evento.fromJson(eventJson)) // Mapea cada tag a la clase Tag
            .toList());
    print(a);
    return a;
  }

  //For listing the userProfiles in the private plan option
  factory UserProfile.fromServerJson(Map<String, dynamic> json) {
    return UserProfile(uuid: json['uuid'], username: json['username']);
  }
}
