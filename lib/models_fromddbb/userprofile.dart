import 'package:worldwildprova/models_fromddbb/activity.dart';
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
  final List<Activity>? activities;

  UserProfile(
      {required this.uuid,
      required this.username,
      this.bio,
      this.originLocation,
      this.userImageUrl,
      //required this.rate,
      this.tags,
      this.activities});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
        uuid: json['uuid'],
        username: json['username'],
        bio: json['bio'],
        originLocation: json['originLocation'],
        userImageUrl: json['image'],
        //rate: json['rate'],
        tags: (json['tags'] as List)
            .map((tagJson) =>
                Tag.fromJson(tagJson)) // Mapea cada tag a la clase Tag
            .toList(),
        activities: (json['activity_detail'] as List)
            .map((activityJson) => Activity.fromJson(
                activityJson, true)) // Mapea cada tag a la clase Tag
            .toList());
  }

  //For listing the userProfiles in the private plan option
  factory UserProfile.fromServerJson(Map<String, dynamic> json) {
    return UserProfile(uuid: json['uuid'], username: json['username']);
  }
}
