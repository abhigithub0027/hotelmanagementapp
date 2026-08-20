import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends StatefulWidget {
  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = Provider.of<AuthProvider>(context, listen: false).user?.uid;
      if (uid != null) {
        Provider.of<BookingProvider>(context, listen: false).listenToBookings(uid);
      }
    });
  }

  void _cancelBooking(String bookingId) {
    final uid = Provider.of<AuthProvider>(context, listen: false).user?.uid;
    if (uid != null) {
      Provider.of<BookingProvider>(context, listen: false).cancelBooking(uid, bookingId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingProvider.bookings.isEmpty
              ? const Center(child: Text('No bookings found.'))
              : ListView.builder(
                  itemCount: bookingProvider.bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookingProvider.bookings[index];
                    final checkIn = DateTime.tryParse(booking.checkInDate);
                    final checkOut = DateTime.tryParse(booking.checkOutDate);
                    
                    final dateStr = checkIn != null && checkOut != null
                        ? '${DateFormat('MMM d').format(checkIn)} - ${DateFormat('MMM d').format(checkOut)}'
                        : 'Invalid dates';
                        
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(booking.hotelName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateStr),
                            Text('Status: ${booking.status}', 
                                style: TextStyle(color: booking.status == 'confirmed' ? Colors.green : Colors.red)),
                          ],
                        ),
                        trailing: booking.status == 'confirmed'
                            ? TextButton(
                                onPressed: () => _cancelBooking(booking.id),
                                child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
