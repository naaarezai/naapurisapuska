import 'package:flutter/material.dart';
import '../models/food_item.dart';

class FilterDialog extends StatefulWidget {
  final FoodCategory? selectedCategory;
  final double? maxDistance;

  const FilterDialog({
    super.key,
    this.selectedCategory,
    this.maxDistance,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  FoodCategory? _selectedCategory;
  double? _maxDistance;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _maxDistance = widget.maxDistance;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Suodata ilmoituksia'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategoria
          const Text(
            'Kategoria',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildCategoryChip(null, 'Kaikki'),
              ...FoodCategory.values.map((category) {
                return _buildCategoryChip(category, category.displayName);
              }),
            ],
          ),
          const SizedBox(height: 24),
          
          // Etäisyys
          const Text(
            'Maksimietäisyys',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildDistanceChip(null, 'Kaikki'),
              _buildDistanceChip(1.0, 'Alle 1km'),
              _buildDistanceChip(5.0, 'Alle 5km'),
              _buildDistanceChip(10.0, 'Alle 10km'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Peruuta'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _selectedCategory = null;
              _maxDistance = null;
            });
          },
          child: const Text('Tyhjennä'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'category': _selectedCategory,
              'maxDistance': _maxDistance,
            });
          },
          child: const Text('Käytä'),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(FoodCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
    );
  }

  Widget _buildDistanceChip(double? distance, String label) {
    final isSelected = _maxDistance == distance;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _maxDistance = selected ? distance : null;
        });
      },
    );
  }
}
