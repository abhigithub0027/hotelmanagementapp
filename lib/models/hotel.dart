class Hotel {
  final String id;
  final String name;
  final String imageUrl;
  final String location;
  final String city;
  final double rating;
  final double price;
  final bool isAvailable;
  final List<String> amenities;
  final double? latitude;
  final double? longitude;

  Hotel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.city,
    required this.rating,
    required this.price,
    required this.isAvailable,
    required this.amenities,
    this.latitude,
    this.longitude,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      price: (json['price'] ?? 0.0).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      amenities: List<String>.from(json['amenities'] ?? []),
      latitude: json['latitude'] != null ? (json['latitude']).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude']).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'location': location,
      'city': city,
      'rating': rating,
      'price': price,
      'isAvailable': isAvailable,
      'amenities': amenities,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
