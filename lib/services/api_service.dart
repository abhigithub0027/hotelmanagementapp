import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';

class ApiService {
  // Simulating a Swagger/OpenAPI endpoint using a mock service
  // In a real scenario, this would use the 'http' package to call the actual endpoint.
  Future<List<Hotel>> fetchHotels({
    String? query,
    String? city,
    double? maxPrice,
    double? minRating,
    String? amenity,
  }) async {
    const String rapidApiKey =
        '4b1fe278e5mshea35f665c087478p13e52djsn6534b0978131'; // TODO: Paste your RapidAPI Key here

    List<Hotel> sourceHotels = [];
    bool useFallback = true;

    if (rapidApiKey.isNotEmpty) {
      try {
        // Example integration with Booking.com RapidAPI (Searching New York City as default)
        // final url = Uri.parse('https://booking-com.p.rapidapi.com/v1/hotels/search?dest_id=-2092174&dest_type=city&room_number=1&checkout_date=2024-12-15&checkin_date=2024-12-14&adults_number=2&order_by=popularity&filter_by_currency=USD&locale=en-gb');
        final url = Uri.parse('https://api.rerumapp.uk/api/v1/swagger.json');
        final response = await http
            .get(
              url,
              headers: {
                'X-RapidAPI-Key': rapidApiKey,
                'X-RapidAPI-Host': 'booking-com.p.rapidapi.com',
              },
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);

          if (data['result'] != null) {
            sourceHotels = (data['result'] as List).take(10).map((e) {
              return Hotel(
                id: e['hotel_id']?.toString() ?? UniqueKey().toString(),
                name: e['hotel_name'] ?? 'Unknown Hotel',
                imageUrl:
                    e['main_photo_url']?.toString().replaceFirst(
                      'square60',
                      'max500',
                    ) ??
                    'https://via.placeholder.com/800x400?text=No+Image',
                location: e['address'] ?? 'Unknown Address',
                city: e['city'] ?? city ?? 'New York',
                rating:
                    (e['review_score'] ?? 0.0).toDouble() /
                    2, // Booking is out of 10, ours is out of 5
                price: (e['min_total_price'] ?? 0.0).toDouble(),
                isAvailable: true,
                amenities: [
                  'Free WiFi',
                  'AC',
                ], // Simplified for search endpoint
                latitude: e['latitude'] != null
                    ? double.tryParse(e['latitude'].toString())
                    : null,
                longitude: e['longitude'] != null
                    ? double.tryParse(e['longitude'].toString())
                    : null,
              );
            }).toList();

            useFallback = false;
          }
        }
      } catch (e) {
        print('Live API failed, falling back to mock data: $e');
      }
    }

    if (useFallback) {
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network delay
      sourceHotels = _mockHotels;
    }

    List<Hotel> filtered = List.from(sourceHotels);

    if (query != null && query.isNotEmpty) {
      filtered = filtered
          .where((h) => h.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    if (city != null && city.isNotEmpty) {
      filtered = filtered
          .where((h) => h.city.toLowerCase().contains(city.toLowerCase()))
          .toList();
    }

    if (maxPrice != null) {
      filtered = filtered.where((h) => h.price <= maxPrice).toList();
    }

    if (minRating != null) {
      filtered = filtered.where((h) => h.rating >= minRating).toList();
    }

    if (amenity != null && amenity.isNotEmpty && amenity != 'All') {
      filtered = filtered.where((h) => h.amenities.contains(amenity)).toList();
    }

    return filtered;
  }

  Future<Hotel> getHotelDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockHotels.firstWhere(
      (h) => h.id == id,
      orElse: () => throw Exception('Hotel not found'),
    );
  }

  final List<Hotel> _mockHotels = [
    Hotel(
      id: '1',
      name: 'Grand Plaza Resort',
      imageUrl:
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
      location: 'Downtown Boulevard',
      city: 'New York',
      rating: 4.8,
      price: 250.0,
      isAvailable: true,
      amenities: ['Free WiFi', 'Pool', 'Gym', 'Spa'],
      latitude: 40.7128,
      longitude: -74.0060,
    ),
    Hotel(
      id: '2',
      name: 'Oceanview Retreat',
      imageUrl:
          'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=800&q=80',
      location: 'Coastal Highway',
      city: 'Miami',
      rating: 4.5,
      price: 180.0,
      isAvailable: true,
      amenities: ['Free WiFi', 'Beach Access', 'Bar', 'Restaurant'],
      latitude: 25.7617,
      longitude: -80.1918,
    ),
    Hotel(
      id: '3',
      name: 'Mountain Peak Inn',
      imageUrl:
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=800&q=80',
      location: 'Alpine Road',
      city: 'Denver',
      rating: 4.2,
      price: 120.0,
      isAvailable: true,
      amenities: ['Free Parking', 'Skiing', 'Fireplace'],
      latitude: 39.7392,
      longitude: -104.9903,
    ),
    Hotel(
      id: '4',
      name: 'City Center Suites',
      imageUrl:
          'https://images.unsplash.com/photo-1551882547-ff40c0d5bf8f?auto=format&fit=crop&w=800&q=80',
      location: 'Market Street',
      city: 'San Francisco',
      rating: 4.6,
      price: 300.0,
      isAvailable: false,
      amenities: ['Business Center', 'Gym', 'Restaurant'],
      latitude: 37.7749,
      longitude: -122.4194,
    ),
    Hotel(
      id: '5',
      name: 'Desert Oasis Hotel',
      imageUrl:
          'https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=800&q=80',
      location: 'Sand Dune Ave',
      city: 'Las Vegas',
      rating: 4.1,
      price: 90.0,
      isAvailable: true,
      amenities: ['Pool', 'Casino', 'Spa'],
      latitude: 36.1699,
      longitude: -115.1398,
    ),
  ];
}
