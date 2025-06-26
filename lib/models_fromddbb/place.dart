class Place {
  final String uuid;
  final int id;
  final String name;
  final String description;
  final double latitud;
  final double longitud;
  final String? imageUrl;

  Place(
      {
      required this.uuid,  
      required this.id,
      required this.name,
      required this.description,
      required this.latitud,
      required this.longitud,
      this.imageUrl});

  // Método para convertir el JSON recibido en un objeto Place
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      uuid: json['uuid'],
      id: json['id'],
      name: json['name'],
      description: json['desc'],
      latitud: json['latitude'] != null ? json['latitude'].toDouble() : 0.0,
      longitud: json['longitude'] != null ? json['longitude'].toDouble() : 0.0,
      imageUrl: 'http://192.168.0.17:8000' + json['image'],
    );
  }
}
