import 'package:flutter/material.dart';
import 'package:worldwildprova/aux/iconsMap.dart';

class Tag {
  final int id;
  final String name;
  final String icon;
  //final IconData icon;

  Tag({required this.id, required this.name, required this.icon});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
        id: json['id'],
        name: json['name'],
        icon: json['icon'] //iconMap[json['id']] ?? Icons.help_outline,
        );
  }
}
