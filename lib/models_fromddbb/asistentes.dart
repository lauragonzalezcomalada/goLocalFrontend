class Usuario {
  final String uuid;
  final String name;
  final String? asistenteImageUrl;

  Usuario({required this.uuid, required this.name, this.asistenteImageUrl});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
        uuid: json['uuid'],
        name: json['username'],
        asistenteImageUrl: json['image']);
  }
}
