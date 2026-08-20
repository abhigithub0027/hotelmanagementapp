import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel.dart';
import '../models/booking.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Favorites
  Future<void> addFavorite(String uid, Hotel hotel) async {
    await _db.collection('users').doc(uid).collection('favorites').doc(hotel.id).set(hotel.toJson());
  }

  Future<void> removeFavorite(String uid, String hotelId) async {
    await _db.collection('users').doc(uid).collection('favorites').doc(hotelId).delete();
  }

  Stream<List<Hotel>> getFavoritesStream(String uid) {
    return _db.collection('users').doc(uid).collection('favorites').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Hotel.fromJson(doc.data())).toList();
    });
  }

  // Bookings
  Future<void> createBooking(String uid, Booking booking) async {
    await _db.collection('users').doc(uid).collection('reservations').add(booking.toJson());
  }

  Future<void> cancelBooking(String uid, String bookingId) async {
    await _db.collection('users').doc(uid).collection('reservations').doc(bookingId).update({'status': 'cancelled'});
  }

  Stream<List<Booking>> getBookingsStream(String uid) {
    return _db.collection('users').doc(uid).collection('reservations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Booking.fromJson(doc.data(), doc.id)).toList();
    });
  }
}
