class Campo {
  String? uuid;
  String label;
  String? type;
  String? nombre;

  Campo({this.uuid, required this.label, this.type, this.nombre});

  factory Campo.fromJson(Map<String, dynamic> json) {
    return Campo(
        uuid: json['uuid'] ?? '',
        label: json['label'],
        type: json['tipo'] ?? '',
        nombre: json['nombre'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'label': label,
    };
  }
}
