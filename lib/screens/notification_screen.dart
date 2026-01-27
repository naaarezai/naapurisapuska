import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item.dart';
import '../services/database_service.dart';
import '../widgets/food_card.dart';
import '../l10n/app_localizations.dart';
import 'food_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  final Set<String> dismissedIds;
  final Function(String) onDismiss;
  final Position? userPosition;

  const NotificationScreen({
    super.key,
    required this.dismissedIds,
    required this.onDismiss,
    this.userPosition,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final DatabaseService _databaseService = DatabaseService();
  StreamSubscription<List<FoodItem>>? _subscription;
  List<FoodItem> _allItems = [];

  @override
  void initState() {
    super.initState();
    _subscription = _databaseService.getRecentFoodItemsStream().listen((items) {
      if (mounted) setState(() => _allItems = items);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
      ),
      body: _buildFoodList(),
    );
  }

  Widget _buildFoodList() {
    final now = DateTime.now();
    final double maxDistanceKm = 20.0; // Filter items within 20km
    final user = FirebaseAuth.instance.currentUser;
    final currentUserId = user?.uid;

    final recentItems = _allItems.where((item) {
      final diff = now.difference(item.timestamp);
      final isRecent = diff.inHours < 24;

      final isNotDismissed = !widget.dismissedIds.contains(item.id);
      final isNotOwnItem = item.userId != currentUserId;

      // Distance check
      bool isNearby = true;
      if (widget.userPosition != null) {
        final distanceInMeters = Geolocator.distanceBetween(
          widget.userPosition!.latitude,
          widget.userPosition!.longitude,
          item.latitude,
          item.longitude,
        );
        isNearby = (distanceInMeters / 1000) <= maxDistanceKm;
      }

      return isRecent && isNotDismissed && isNearby && isNotOwnItem;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (recentItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.noNewNotifications,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (widget.userPosition != null) ...[
              const SizedBox(height: 8),
              Text(
                '(${AppLocalizations.of(context)!.distanceUnitKm} < ${maxDistanceKm.toInt()})',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              )
            ]
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentItems.length,
      itemBuilder: (context, index) {
        final item = recentItems[index];
        return Dismissible(
          key: Key(item.id),
          onDismissed: (direction) => widget.onDismiss(item.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: FoodCard(
            foodItem: item,
            userPosition:
                widget.userPosition, // Pass user position for distance display
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDetailScreen(
                    foodItem: item,
                    userPosition: widget.userPosition,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
