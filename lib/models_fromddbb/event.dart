class Event {
  final String uuid;
  final String name;
  final String? shortDesc;
  final String? desc;
  //final int type;
  final String? placeName;
  final String? activityImageUrl;
  final DateTime dateTime;
  final bool gratis;
  final double? price;
  final bool? created_by_user;
  final bool? going;
  final double? lat;
  final double? long;

  Event(
      {required this.uuid,
      required this.name,
      this.shortDesc,
      this.desc,
      this.placeName,
      this.activityImageUrl,
      required this.dateTime,
      required this.gratis,
      this.price,
      this.created_by_user,
      this.going,
      this.lat,
      this.long});
}
