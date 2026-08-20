import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class BookingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenToBookings(String uid) {
    _isLoading = true;
    notifyListeners();
    try {
      _firestoreService.getBookingsStream(uid).listen((bookingsList) {
        _bookings = bookingsList;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking(String uid, String hotelId, String hotelName, DateTime checkIn, DateTime checkOut) async {
    try {
      final booking = Booking(
        id: const Uuid().v4(), // Generate temporary ID
        hotelId: hotelId,
        hotelName: hotelName,
        checkInDate: checkIn.toIso8601String(),
        checkOutDate: checkOut.toIso8601String(),
        status: 'confirmed',
      );
      await _firestoreService.createBooking(uid, booking);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> cancelBooking(String uid, String bookingId) async {
    try {
      await _firestoreService.cancelBooking(uid, bookingId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
