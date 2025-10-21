class Message {
  final String uuid;
  final DateTime dateTime;
  final String message;
  bool read;

  Message(
      {required this.uuid,
      required this.dateTime,
      required this.message,
      required this.read});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        dateTime: DateTime.parse(json['dateTime']).toLocal(),
        uuid: json['uuid'],
        message: json['message'],
        read: json['read']);
  }
}
