import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item.dart';
import '../screens/food_detail_screen.dart';
import '../services/favorite_service.dart';
import '../utils/haptic_helper.dart';

class FoodCard extends StatefulWidget {
  final FoodItem foodItem;
  final String? distance;

  const FoodCard({
    super.key,
    required this.foodItem,
    this.distance,
  });

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  final FavoriteService _favoriteService = FavoriteService();

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} päivää sitten';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h sitten';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min sitten';
    } else {
      return 'Juuri nyt';
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    HapticHelper.selectionClick();

    try {
      final isFavorite = await _favoriteService.isFavorite(widget.foodItem.id);
      if (isFavorite) {
        await _favoriteService.removeFavorite(widget.foodItem.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Poistettu suosikeista'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        await _favoriteService.addFavorite(widget.foodItem.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lisätty suosikkeihin'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Virhe: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.foodItem.id),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Row(
          children: [
            Icon(Icons.favorite, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Text(
              'Suosikki',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFF8F00),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Varaa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 12),
            Icon(Icons.check_circle, color: Colors.white, size: 32),
          ],
        ),
      ),
      onDismissed: (direction) async {
        HapticHelper.mediumImpact();
        
        if (direction == DismissDirection.startToEnd) {
          // Vedetty vasemmalta oikealle → Suosikki
          await _toggleFavorite();
        } else if (direction == DismissDirection.endToStart) {
          // Vedetty oikealta vasemmalle → Varaa
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kirjaudu sisään varataksesi'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }
          
          // Navigoi detail-näyttöön, jossa voi varata
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDetailScreen(
                  foodItem: widget.foodItem,
                  userPosition: null,
                ),
              ),
            );
          }
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDetailScreen(
                  foodItem: widget.foodItem,
                  userPosition: null,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kuva vasemmalla
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: widget.foodItem.imageUrl.isNotEmpty
                        ? Hero(
                            tag: 'food_image_${widget.foodItem.id}',
                            child: CachedNetworkImage(
                              imageUrl: widget.foodItem.imageUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                  ),
                  if (widget.foodItem.isReserved)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Sisältö oikealla
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- KORJATTU OSA: Wrap estää ylivuodon ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Vasen puoli (Kategoria + Varattu) - Saa rivittyä
                          Expanded(
                            child: Wrap(
                              spacing: 8, 
                              runSpacing: 4, 
                              children: [
                                // Kategoria
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF388E3C).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.foodItem.category.displayName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF388E3C),
                                    ),
                                  ),
                                ),
                                // Varattu-merkki
                                if (widget.foodItem.isReserved)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 10,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Varattu',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          // Oikea puoli (Hinta) - Pysyy aina oikealla
                          const SizedBox(width: 8),
                          if (widget.foodItem.price != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF8F00).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '€${widget.foodItem.price!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF8F00),
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF388E3C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Ilmainen',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF388E3C),
                                ),
                              ),
                            ),
                        ],
                      ),
                      // ------------------------------------------

                      const SizedBox(height: 8),
                      // Otsikko ja suosikki-nappi
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.foodItem.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StreamBuilder<List<String>>(
                            stream: _favoriteService.getFavoriteIdsStream(),
                            builder: (context, snapshot) {
                              final isFavorite = snapshot.hasData &&
                                  snapshot.data!.contains(widget.foodItem.id);
                              
                              return IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.grey,
                                  size: 20,
                                ),
                                onPressed: _toggleFavorite,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Määrä (jos saatavilla)
                      if (widget.foodItem.quantity != null && widget.foodItem.quantityUnit != null) ...[
                        Text(
                          '${widget.foodItem.quantity!.toStringAsFixed(widget.foodItem.quantity! % 1 == 0 ? 0 : 1)} ${widget.foodItem.quantityUnit}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF388E3C),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      // Kuvaus
                      Text(
                        widget.foodItem.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Aikaleima ja etäisyys
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(widget.foodItem.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (widget.distance != null) ...[
                            const SizedBox(width: 16),
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.distance!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}