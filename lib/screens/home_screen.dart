import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hotel_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/hotel_card.dart';
import '../widgets/filter_dialog.dart';
import 'hotel_details_screen.dart';
import 'favorites_screen.dart';
import 'bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  double? _maxPrice;
  double? _minRating;
  String? _amenity;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final provider = Provider.of<HotelProvider>(context, listen: false);

      await provider.loginToReRum(
        username: 'YOUR_RERUM_USERNAME',
        password: 'YOUR_RERUM_PASSWORD',
      );
    });
  }

  void _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FilterDialog(
        initialMaxPrice: _maxPrice,
        initialMinRating: _minRating,
        initialAmenity: _amenity,
      ),
    );

    if (result != null) {
      setState(() {
        _maxPrice = result['maxPrice'];
        _minRating = result['minRating'];
        _amenity = result['amenity'] == 'All' ? null : result['amenity'];
      });
      _onSearch(_searchCtrl.text);
    }
  }

  // void _onSearch(String query) {
  //   Provider.of<HotelProvider>(context, listen: false).fetchHotels(
  //     query: query,
  //     maxPrice: _maxPrice,
  //     minRating: _minRating,
  //     amenity: _amenity,
  //   );
  // }
  Timer? _searchTimer;

  void _onSearch(String query) {
    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      Provider.of<HotelProvider>(context, listen: false).fetchHotels(
        query: query,
        maxPrice: _maxPrice,
        minRating: _minRating,
        amenity: _amenity,
      );
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Hotels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FavoritesScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookingsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search by property name...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _onSearch,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.blue),
                    onPressed: _showFilterDialog,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: hotelProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : hotelProvider.error != null
                ? Center(child: Text("Server error 403"))
                : hotelProvider.hotels.isEmpty
                ? const Center(child: Text('No hotels found.'))
                : RefreshIndicator(
                    onRefresh: () => hotelProvider.fetchHotels(),
                    child: ListView.builder(
                      itemCount: hotelProvider.hotels.length,
                      itemBuilder: (context, index) {
                        final hotel = hotelProvider.hotels[index];
                        return HotelCard(
                          hotel: hotel,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HotelDetailsScreen(hotelId: hotel.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
