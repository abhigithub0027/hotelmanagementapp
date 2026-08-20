class Hotel {
  final String id;
  final String name;
  final String description;
  final String city;
  final String location;
  final String country;
  final double price;
  final double rating;
  final List<String> amenities;
  final List<String> images;
  final bool isAvailable;
  final double? latitude;
  final double? longitude;
  final String propertyType;
  final int maxOccupancy;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.location,
    required this.country,
    required this.price,
    required this.rating,
    required this.amenities,
    required this.images,
    required this.isAvailable,
    this.latitude,
    this.longitude,
    required this.propertyType,
    required this.maxOccupancy,
  });

  factory Hotel.fromReRumJson(Map<String, dynamic> json) {
    final address = json['propertyAddress'] is Map
        ? Map<String, dynamic>.from(json['propertyAddress'])
        : <String, dynamic>{};

    final city = address['city']?.toString() ?? '';
    final country = address['country']?.toString() ?? '';

    final List<String> imageUrls = [];

    final mainImage = json['mainImage'];
    if (mainImage is Map && mainImage['url'] != null) {
      imageUrls.add(mainImage['url'].toString());
    }

    final images = json['images'];
    if (images is List) {
      for (final image in images) {
        if (image is Map && image['url'] != null) {
          final url = image['url'].toString();
          if (!imageUrls.contains(url)) {
            imageUrls.add(url);
          }
        }
      }
    }

    final List<String> amenities = [];
    final features = json['features'];
    if (features is List) {
      for (final feature in features) {
        if (feature is Map && feature['name'] != null) {
          amenities.add(feature['name'].toString());
        }
      }
    }

    final location = json['location']?.toString() ??
        [
          address['addressLine1'],
          address['addressLine2'],
          address['addressLine3'],
          address['city'],
          address['postCode'],
          address['country'],
        ]
            .where((e) => e != null && e.toString().trim().isNotEmpty)
            .join(', ');

    final latitude = _toDouble(json['latitude']);
    final longitude = _toDouble(json['longitude']);
    final occupancy = _toInt(json['maxOccupancy']) ?? 0;

    return Hotel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Property',
      description: json['description']?.toString() ??
          json['shortDescription']?.toString() ??
          '',
      city: city,
      location: location,
      country: country,
      rating: 0.0,
      price: 0.0,
      amenities: amenities,
      images: imageUrls,
      isAvailable: json['isAvailable'] != false,
      latitude: latitude,
      longitude: longitude,
      propertyType: json['propertyType']?.toString() ?? '',
      maxOccupancy: occupancy,
    );
  }

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      price: _toDouble(json['price']) ?? 0.0,
      rating: _toDouble(json['rating']) ?? 0.0,
      amenities: (json['amenities'] as List?)?.map((e) => e.toString()).toList() ?? [],
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isAvailable: json['isAvailable'] != false,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      propertyType: json['propertyType']?.toString() ?? '',
      maxOccupancy: _toInt(json['maxOccupancy']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'city': city,
      'location': location,
      'country': country,
      'price': price,
      'rating': rating,
      'amenities': amenities,
      'images': images,
      'isAvailable': isAvailable,
      'latitude': latitude,
      'longitude': longitude,
      'propertyType': propertyType,
      'maxOccupancy': maxOccupancy,
    };
  }

  String get imageUrl => images.isNotEmpty ? images.first : '';

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}