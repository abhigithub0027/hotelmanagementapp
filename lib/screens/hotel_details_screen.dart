import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/hotel.dart';
import '../providers/hotel_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/booking_provider.dart';

class HotelDetailsScreen extends StatefulWidget {
  final String hotelId;

  const HotelDetailsScreen({
    super.key,
    required this.hotelId,
  });

  @override
  State<HotelDetailsScreen> createState() =>
      _HotelDetailsScreenState();
}

class _HotelDetailsScreenState
    extends State<HotelDetailsScreen> {

  Hotel? _hotel;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHotelDetails();
  }

  // ------------------------------------------------------------
  // GET /api/v1/properties/{id}
  // ------------------------------------------------------------

  Future<void> _loadHotelDetails() async {
    try {
      final hotelProvider = Provider.of<HotelProvider>(
        context,
        listen: false,
      );

      final hotel = await hotelProvider.getHotelDetails(
        widget.hotelId,
      );

      if (!mounted) return;

      setState(() {
        _hotel = hotel;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // ------------------------------------------------------------
  // Open Google Maps
  // ------------------------------------------------------------

  Future<void> _launchMap() async {
    final hotel = _hotel;

    if (hotel == null) return;

    final lat = hotel.latitude;
    final lng = hotel.longitude;

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location coordinates are not available.',
          ),
        ),
      );
      return;
    }

    final navigationUri = Uri.parse(
      'google.navigation:q=$lat,$lng&mode=d',
    );

    final fallbackUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    try {
      if (await canLaunchUrl(navigationUri)) {
        await launchUrl(
          navigationUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        await launchUrl(
          fallbackUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open Google Maps.',
          ),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // Booking
  // ------------------------------------------------------------

  Future<void> _bookRoom() async {
    final hotel = _hotel;

    if (hotel == null) return;

    final auth = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    if (!auth.isAuthenticated || auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login before booking.',
          ),
        ),
      );
      return;
    }

    final uid = auth.user!.uid;

    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    // Example booking dates.
    // Replace these with your date picker later.
    final checkIn = DateTime.now().add(
      const Duration(days: 1),
    );

    final checkOut = DateTime.now().add(
      const Duration(days: 3),
    );

    final success =
    await bookingProvider.createBooking(
      uid,
      hotel.id,
      hotel.name,
      checkIn,
      checkOut,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Booking confirmed!',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking failed: ${bookingProvider.error}',
          ),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // Favorite
  // ------------------------------------------------------------

  Future<void> _toggleFavorite() async {
    final hotel = _hotel;

    if (hotel == null) return;

    final auth = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    if (!auth.isAuthenticated ||
        auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login to add favorites.',
          ),
        ),
      );
      return;
    }

    final favoriteProvider =
    Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );

    await favoriteProvider.toggleFavorite(
      auth.user!.uid,
      hotel,
    );

    if (!mounted) return;

    setState(() {});
  }

  // ------------------------------------------------------------
  // Image Widget
  // ------------------------------------------------------------

  Widget _buildHotelImage(Hotel hotel) {
    if (hotel.imageUrl.isEmpty) {
      return Container(
        height: 280,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Icon(
          Icons.hotel,
          size: 80,
          color: Colors.grey,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: hotel.imageUrl,
      height: 280,
      width: double.infinity,
      fit: BoxFit.cover,

      placeholder: (context, url) {
        return Container(
          height: 280,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },

      errorWidget: (context, url, error) {
        return Container(
          height: 280,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.hotel,
            size: 80,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // Amenities
  // ------------------------------------------------------------

  Widget _buildAmenities(Hotel hotel) {
    if (hotel.amenities.isEmpty) {
      return const Text(
        'No amenities available.',
        style: TextStyle(
          color: Colors.grey,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: hotel.amenities.map(
            (amenity) {
          return Chip(
            avatar: const Icon(
              Icons.check_circle_outline,
              size: 18,
            ),
            label: Text(amenity),
          );
        },
      ).toList(),
    );
  }

  // ------------------------------------------------------------
  // Google Map
  // ------------------------------------------------------------

  Widget _buildMap(Hotel hotel) {
    if (hotel.latitude == null ||
        hotel.longitude == null) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Map location unavailable',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    final position = LatLng(
      hotel.latitude!,
      hotel.longitude!,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: position,
            zoom: 14,
          ),

          markers: {
            Marker(
              markerId: MarkerId(hotel.id),
              position: position,
              infoWindow: InfoWindow(
                title: hotel.name,
              ),
            ),
          },

          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Section Title
  // ------------------------------------------------------------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Main UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Loading
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Property Details',
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Property Details',
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Unable to load property details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });

                    _loadHotelDetails();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // No hotel
    if (_hotel == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Property Details',
          ),
        ),
        body: const Center(
          child: Text(
            'Property not found.',
          ),
        ),
      );
    }

    final hotel = _hotel!;

    final auth = Provider.of<AuthProvider>(
      context,
    );

    final favoriteProvider =
    Provider.of<FavoriteProvider>(
      context,
    );

    final uid = auth.user?.uid ?? '';

    final isFavorite =
        uid.isNotEmpty &&
            favoriteProvider.isFavorite(
              hotel.id,
            );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hotel.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color:
              isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [

            // --------------------------------------------------
            // Main Image
            // --------------------------------------------------

            _buildHotelImage(hotel),

            // --------------------------------------------------
            // Main Information
            // --------------------------------------------------

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  // Name
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Property Type
                  if (hotel.propertyType.isNotEmpty)
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue
                            .withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      child: Text(
                        hotel.propertyType,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Location
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          [
                            hotel.location,
                            hotel.city,
                            hotel.country,
                          ]
                              .where(
                                (e) =>
                            e.trim().isNotEmpty,
                          )
                              .join(', '),
                          style:
                          const TextStyle(
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --------------------------------------------------
                  // Description
                  // --------------------------------------------------

                  if (hotel.description.isNotEmpty) ...[
                    _sectionTitle(
                      'About this property',
                    ),

                    Text(
                      hotel.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],

                  // --------------------------------------------------
                  // Amenities
                  // --------------------------------------------------

                  _sectionTitle(
                    'Features & Amenities',
                  ),

                  _buildAmenities(hotel),

                  const SizedBox(height: 24),

                  // --------------------------------------------------
                  // Occupancy
                  // --------------------------------------------------

                  if (hotel.maxOccupancy != null) ...[
                    _sectionTitle(
                      'Property Information',
                    ),

                    Container(
                      padding:
                      const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:
                        Colors.grey.shade100,
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 28,
                          ),

                          const SizedBox(width: 12),

                          const Text(
                            'Maximum occupancy',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            '${hotel.maxOccupancy} guests',
                            style: const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],

                  // --------------------------------------------------
                  // Coordinates
                  // --------------------------------------------------

                  if (hotel.latitude != null &&
                      hotel.longitude != null) ...[
                    _sectionTitle(
                      'Location',
                    ),

                    _buildMap(hotel),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Lat: ${hotel.latitude!.toStringAsFixed(6)}\n'
                                'Lng: ${hotel.longitude!.toStringAsFixed(6)}',
                            style:
                            const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        OutlinedButton.icon(
                          onPressed: _launchMap,
                          icon: const Icon(
                            Icons.directions,
                          ),
                          label: const Text(
                            'Directions',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],

                  // --------------------------------------------------
                  // Booking
                  // --------------------------------------------------

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                      hotel.isAvailable
                          ? _bookRoom
                          : null,

                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.green,
                        foregroundColor:
                        Colors.white,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),

                      child: Text(
                        hotel.isAvailable
                            ? 'Book Now'
                            : 'Sold Out',
                        style:
                        const TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}