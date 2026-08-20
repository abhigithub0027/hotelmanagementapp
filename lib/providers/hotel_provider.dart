import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/hotel.dart';
import '../services/api_service.dart';

class HotelProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Hotel> _allHotels = [];
  List<Hotel> _hotels = [];

  bool _isLoading = false;
  String? _error;

  List<Hotel> get hotels => _hotels;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // ==========================================================
  // INITIALIZE API
  // ==========================================================

  Future<void> initializeApi() async {
    await fetchHotels();
  }

  // ==========================================================
  // AUTH + FETCH
  // ==========================================================

  Future<void> loginToReRum({
    required String username,
    required String password,
  }) async {
    try {
      _error = null;
      notifyListeners();

      await _apiService.authenticate(
        username: username,
        password: password,
      );

      await fetchHotels(
        forceRefresh: true,
      );
    } catch (e) {
      _error = e.toString();
      debugPrint(
        'ReRum login error: $e',
      );
      notifyListeners();
    }
  }

  // ==========================================================
  // FETCH HOTELS
  // ==========================================================

  Future<void> fetchHotels({
    String? query,
    String? city,
    double? maxPrice,
    double? minRating,
    String? amenity,
    bool forceRefresh = false,
  }) async {
    _error = null;

    final box = Hive.box('hotels_cache');
    const cacheKey = 'rerum_hotels';

    try {
      // ======================================================
      // CACHE
      // ======================================================

      if (!forceRefresh &&
          box.containsKey(cacheKey)) {
        final cachedData =
        box.get(cacheKey);

        if (cachedData != null) {
          final decoded =
          jsonDecode(
            cachedData.toString(),
          );

          if (decoded is List) {
            _allHotels = decoded
                .map(
                  (item) =>
                  Hotel.fromJson(
                    Map<String, dynamic>.from(
                      item,
                    ),
                  ),
            )
                .toList();

            _applyFilters(
              query: query,
              city: city,
              maxPrice: maxPrice,
              minRating: minRating,
              amenity: amenity,
            );

            _isLoading = false;
            notifyListeners();
          }
        }
      }

      // ======================================================
      // API
      // ======================================================

      _isLoading = true;
      notifyListeners();

      final freshHotels =
      await _apiService.fetchHotels(
        page: 1,
        pageSize: 50,
      );

      _allHotels = freshHotels;

      // ======================================================
      // CACHE
      // ======================================================

      await box.put(
        cacheKey,
        jsonEncode(
          freshHotels
              .map(
                (hotel) => hotel.toJson(),
          )
              .toList(),
        ),
      );

      // ======================================================
      // FILTER
      // ======================================================

      _applyFilters(
        query: query,
        city: city,
        maxPrice: maxPrice,
        minRating: minRating,
        amenity: amenity,
      );
    } catch (e) {
      debugPrint(
        'HotelProvider fetch error: $e',
      );

      if (_allHotels.isEmpty) {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  void _applyFilters({
    String? query,
    String? city,
    double? maxPrice,
    double? minRating,
    String? amenity,
  }) {
    var result =
    List<Hotel>.from(_allHotels);

    if (query != null &&
        query.trim().isNotEmpty) {
      final search =
      query.trim().toLowerCase();

      result = result.where((hotel) {
        return hotel.name
            .toLowerCase()
            .contains(search) ||
            hotel.city
                .toLowerCase()
                .contains(search) ||
            hotel.location
                .toLowerCase()
                .contains(search);
      }).toList();
    }

    if (city != null &&
        city.trim().isNotEmpty) {
      final searchCity =
      city.trim().toLowerCase();

      result = result.where((hotel) {
        return hotel.city
            .toLowerCase()
            .contains(searchCity);
      }).toList();
    }

    if (maxPrice != null) {
      result = result.where((hotel) {
        return hotel.price <= maxPrice;
      }).toList();
    }

    if (minRating != null) {
      result = result.where((hotel) {
        return hotel.rating >= minRating;
      }).toList();
    }

    if (amenity != null &&
        amenity.trim().isNotEmpty &&
        amenity != 'All') {
      final selectedAmenity =
      amenity.trim().toLowerCase();

      result = result.where((hotel) {
        return hotel.amenities.any(
              (item) =>
          item.toLowerCase() ==
              selectedAmenity,
        );
      }).toList();
    }

    _hotels = result;
  }

  // ==========================================================
  // APPLY FILTERS
  // ==========================================================

  void applyFilters({
    String? query,
    String? city,
    double? maxPrice,
    double? minRating,
    String? amenity,
  }) {
    _applyFilters(
      query: query,
      city: city,
      maxPrice: maxPrice,
      minRating: minRating,
      amenity: amenity,
    );

    notifyListeners();
  }

  // ==========================================================
  // DETAILS
  // ==========================================================

  Future<Hotel> getHotelDetails(
      String id,
      ) async {
    return await _apiService
        .getHotelDetails(id);
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}