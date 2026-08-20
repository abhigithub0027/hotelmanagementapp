import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final double? initialMaxPrice;
  final double? initialMinRating;
  final String? initialAmenity;

  const FilterDialog({
    Key? key,
    this.initialMaxPrice,
    this.initialMinRating,
    this.initialAmenity,
  }) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  double _maxPrice = 500.0;
  double _minRating = 0.0;
  String _amenity = 'All';

  final List<String> _amenities = ['All', 'Free WiFi', 'Pool', 'Gym', 'Spa', 'Restaurant', 'Beach Access'];

  @override
  void initState() {
    super.initState();
    _maxPrice = widget.initialMaxPrice ?? 500.0;
    _minRating = widget.initialMinRating ?? 0.0;
    _amenity = widget.initialAmenity ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Hotels'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Max Price: \$${_maxPrice.toStringAsFixed(0)}'),
            Slider(
              value: _maxPrice,
              min: 50.0,
              max: 1000.0,
              divisions: 19,
              onChanged: (val) => setState(() => _maxPrice = val),
            ),
            const SizedBox(height: 16),
            Text('Min Rating: ${_minRating.toStringAsFixed(1)} Stars'),
            Slider(
              value: _minRating,
              min: 0.0,
              max: 5.0,
              divisions: 10,
              onChanged: (val) => setState(() => _minRating = val),
            ),
            const SizedBox(height: 16),
            const Text('Amenity:'),
            DropdownButton<String>(
              isExpanded: true,
              value: _amenities.contains(_amenity) ? _amenity : 'All',
              items: _amenities.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _amenity = val ?? 'All';
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _maxPrice = 500.0;
              _minRating = 0.0;
              _amenity = 'All';
            });
          },
          child: const Text('Clear'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'maxPrice': _maxPrice,
              'minRating': _minRating,
              'amenity': _amenity,
            });
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
