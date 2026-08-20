import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/hotel_card.dart';
import 'hotel_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = Provider.of<AuthProvider>(context, listen: false).user?.uid;
      if (uid != null) {
        Provider.of<FavoriteProvider>(context, listen: false).listenToFavorites(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoriteProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : favProvider.favorites.isEmpty
              ? const Center(child: Text('No favorites yet.'))
              : ListView.builder(
                  itemCount: favProvider.favorites.length,
                  itemBuilder: (context, index) {
                    final hotel = favProvider.favorites[index];
                    return HotelCard(
                      hotel: hotel,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HotelDetailsScreen(hotel: hotel)),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
