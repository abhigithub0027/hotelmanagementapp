import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/hotel.dart';
import '../services/api_service.dart';

class HotelProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Hotel> _hotels = [];
  bool _isLoading = false;
  String? _error;

  List<Hotel> get hotels => _hotels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchHotels({
    String? query,
    String? city,
    double? maxPrice,
    double? minRating,
    String? amenity,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Try to load from Hive Cache first (for instant display)
      final box = Hive.box('hotels_cache');
      final String cacheKey = 'hotels_${query ?? ''}_${city ?? ''}_${maxPrice ?? ''}_${minRating ?? ''}_${amenity ?? ''}';
      
      if (box.containsKey(cacheKey)) {
        final String cachedData = box.get(cacheKey);
        final List<dynamic> decoded = jsonDecode(cachedData);
        _hotels = decoded.map((e) => Hotel.fromJson(e)).toList();
        _isLoading = false;
        notifyListeners(); // Update UI immediately with cached data
      }

      // 2. Fetch fresh data from API
      final freshHotels = await _apiService.fetchHotels(
        query: query,
        city: city,
        maxPrice: maxPrice,
        minRating: minRating,
        amenity: amenity,
      );
      _hotels = freshHotels;
      
      // 3. Save fresh data to Cache
      final String freshJson = jsonEncode(freshHotels.map((h) => h.toJson()).toList());
      await box.put(cacheKey, freshJson);

    } catch (e) {
      if (_hotels.isEmpty) {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
