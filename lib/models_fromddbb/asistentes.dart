class Asistente {
  final String uuid;
  final String name;
  final String? asistenteImageUrl;

  Asistente({required this.uuid, required this.name, this.asistenteImageUrl});

  factory Asistente.fromJson(Map<String, dynamic> json) {
    return Asistente(
        uuid: json['uuid'],
        name: json['username'],
        asistenteImageUrl: json['image']);
  }
}
