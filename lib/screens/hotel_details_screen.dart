import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/hotel.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/booking_provider.dart';

class HotelDetailsScreen extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailsScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  _HotelDetailsScreenState createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  Future<void> _launchMap() async {
    final lat = widget.hotel.latitude;
    final lng = widget.hotel.longitude;
    
    if (lat != null && lng != null) {
      final uri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
      final fallbackUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open map.')));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location not available.')));
    }
  }

  void _bookRoom() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) return;
    
    final uid = auth.user!.uid;
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    
    // Simulate booking dates
    final checkIn = DateTime.now().add(const Duration(days: 1));
    final checkOut = DateTime.now().add(const Duration(days: 3));
    
    final success = await bookingProvider.createBooking(uid, widget.hotel.id, widget.hotel.name, checkIn, checkOut);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking confirmed!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${bookingProvider.error}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final favProvider = Provider.of<FavoriteProvider>(context);
    
    final uid = auth.user?.uid ?? '';
    final isFav = favProvider.isFavorite(widget.hotel.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotel.name),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
            onPressed: () {
              if (uid.isNotEmpty) favProvider.toggleFavorite(uid, widget.hotel);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CachedNetworkImage(
              imageUrl: widget.hotel.imageUrl,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(widget.hotel.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      Text('\$${widget.hotel.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('${widget.hotel.location}, ${widget.hotel.city}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Amenities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.hotel.amenities.map((a) => Chip(label: Text(a))).toList(),
                  ),
                  if (widget.hotel.latitude != null && widget.hotel.longitude != null) ...[
                    const SizedBox(height: 24),
                    const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(widget.hotel.latitude!, widget.hotel.longitude!),
                          zoom: 14.0,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(widget.hotel.id),
                            position: LatLng(widget.hotel.latitude!, widget.hotel.longitude!),
                            infoWindow: InfoWindow(title: widget.hotel.name),
                          ),
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.hotel.isAvailable ? _bookRoom : null,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: Text(widget.hotel.isAvailable ? 'Book Now' : 'Sold Out'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
