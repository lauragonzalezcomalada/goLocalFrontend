import 'package:worldwildprova/models_fromddbb/userprofile.dart';

class Item {
  final String uuid;
  final String name;
  final double neededAmount;
  final double assignedAmount;
  final List<UserProfile> peopleInCharge;

  Item(
      {required this.uuid,
      required this.name,
      required this.neededAmount,
      required this.assignedAmount,
      required this.peopleInCharge});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        uuid: json['uuid'],
        name: json['name'],
        neededAmount: json['neededAmount'],
        assignedAmount: json['assignedAmount'],
        peopleInCharge: (json['people_in_charge'] as List)
            .map((userProfile) => UserProfile.fromServerJson(userProfile))
            .toList());
  }
}
