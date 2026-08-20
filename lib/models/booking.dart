class Booking {
  final String id;
  final String hotelId;
  final String hotelName;
  final String checkInDate;
  final String checkOutDate;
  final String status;

  Booking({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json, String documentId) {
    return Booking(
      id: documentId,
      hotelId: json['hotelId'] ?? '',
      hotelName: json['hotelName'] ?? '',
      checkInDate: json['checkInDate'] ?? '',
      checkOutDate: json['checkOutDate'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotelId': hotelId,
      'hotelName': hotelName,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'status': status,
    };
  }
}
