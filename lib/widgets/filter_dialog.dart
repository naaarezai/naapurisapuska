import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../utils/app_theme.dart';
import '../utils/haptic_helper.dart';
import '../l10n/app_localizations.dart';
import '../utils/category_helper.dart';

class FilterDialog extends StatefulWidget {
  final FoodCategory? selectedCategory;
  final double? maxDistance;
  final List<String>? selectedTags;

  const FilterDialog({
    super.key,
    this.selectedCategory,
    this.maxDistance,
    this.selectedTags,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  FoodCategory? _selectedCategory;
  double? _currentDistance;
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _currentDistance = widget.maxDistance;
    _selectedTags = List.from(widget.selectedTags ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.filter,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticHelper.mediumImpact();
                    Navigator.pop(context, {
                      'category': null,
                      'maxDistance': null,
                      'tags': null,
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.clear),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategoria
                    Text(
                      AppLocalizations.of(context)!.filterCategory,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildCategoryChip(
                            null, AppLocalizations.of(context)!.categoryAll),
                        ...FoodCategory.values.map((category) {
                          return _buildCategoryChip(
                              category,
                              CategoryHelper.getCategoryName(
                                  category, context));
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Etäisyys
                    Text(
                      AppLocalizations.of(context)!.filterDistance,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                            '1 ${AppLocalizations.of(context)!.distanceUnitKm}'),
                        Expanded(
                          child: Slider(
                            value: _currentDistance ?? 20.0,
                            min: 1.0,
                            max: 20.0,
                            divisions: 19,
                            label: _currentDistance == null
                                ? AppLocalizations.of(context)!.noLimit
                                : '${_currentDistance!.toInt()} ${AppLocalizations.of(context)!.distanceUnitKm}',
                            activeColor: _currentDistance == null
                                ? Colors.grey
                                : AppTheme.primaryGreen,
                            onChanged: (value) {
                              setState(() {
                                _currentDistance = value;
                              });
                            },
                          ),
                        ),
                        Text(_currentDistance == null
                            ? AppLocalizations.of(context)!.noLimit
                            : '${_currentDistance!.toInt()} ${AppLocalizations.of(context)!.distanceUnitKm}'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Erityisruokavaliot
                    Text(
                      AppLocalizations.of(context)!.filterDiets,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: FoodItem.availableTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(CategoryHelper.getTagName(tag, context)),
                          selected: isSelected,
                          onSelected: (selected) {
                            HapticHelper.selectionClick();
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticHelper.mediumImpact();
                      Navigator.pop(context, {
                        'category': _selectedCategory,
                        'maxDistance': _currentDistance,
                        'tags': _selectedTags,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(AppLocalizations.of(context)!.showResults),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(FoodCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        HapticHelper.selectionClick();
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? AppTheme.primaryGreen
            : Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: AppTheme.primaryGreen,
    );
  }
}
