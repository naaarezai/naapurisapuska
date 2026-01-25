import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item.dart';
import '../services/user_service.dart';
import '../widgets/food_card.dart';
import 'food_detail_screen.dart';
import '../services/database_service.dart';
import '../services/rating_service.dart';
import '../models/user_model.dart';

class FoodListScreen extends StatefulWidget {
  final String title;
  final List<FoodItem> items;
  final String emptyMessage;
  final UserService? userService;
  final DatabaseService? databaseService;
  final RatingService? ratingService;
  final FirebaseAuth? auth;

  const FoodListScreen({
    super.key,
    required this.title,
    required this.items,
    required this.emptyMessage,
    this.userService,
    this.databaseService,
    this.ratingService,
    this.auth,
  });

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  late List<FoodItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    final UserService userService = widget.userService ?? UserService();
    final auth = widget.auth ?? FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    widget.emptyMessage,
                    style: TextStyle(
                      color: Theme.of(context).disabledColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : StreamBuilder<UserModel?>(
              stream: currentUser != null
                  ? userService.getUserStream(currentUser.uid)
                  : Stream.value(null),
              builder: (context, userSnapshot) {
                final favoriteIds = userSnapshot.data?.favorites.toSet() ?? {};

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return FoodCard(
                      foodItem: item,
                      isFavorite: favoriteIds.contains(item.id),
                      onFavoriteToggle: () async {
                        if (currentUser != null) {
                          await userService.toggleFavorite(
                              currentUser.uid, item.id);
                        }
                      },
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDetailScreen(
                              foodItem: item,
                              databaseService: widget.databaseService,
                              ratingService: widget.ratingService,
                              auth: widget.auth,
                            ),
                          ),
                        );

                        if (result == true) {
                          setState(() {
                            _items.removeAt(index);
                          });
                        }
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
