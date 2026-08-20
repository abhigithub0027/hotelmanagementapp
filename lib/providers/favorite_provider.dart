import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/firestore_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Hotel> _favorites = [];
  bool _isLoading = false;

  List<Hotel> get favorites => _favorites;
  bool get isLoading => _isLoading;

  void listenToFavorites(String uid) {
    _isLoading = true;
    notifyListeners();
    try {
      _firestoreService.getFavoritesStream(uid).listen((hotels) {
        _favorites = hotels;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String uid, Hotel hotel) async {
    try {
      final isFavorite = _favorites.any((h) => h.id == hotel.id);
      if (isFavorite) {
        await _firestoreService.removeFavorite(uid, hotel.id);
      } else {
        await _firestoreService.addFavorite(uid, hotel);
      }
    } catch (e) {
      print(e);
    }
  }

  bool isFavorite(String hotelId) {
    return _favorites.any((h) => h.id == hotelId);
  }
}
