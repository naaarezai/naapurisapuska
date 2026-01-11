import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item.dart';
import '../services/rating_service.dart';
import '../services/database_service.dart';
import 'chat_screen.dart';
import 'edit_food_screen.dart'; // Lisää tämä import muokkausta varten
import '../utils/error_helper.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;
  final Position? userPosition;

  const FoodDetailScreen({
    super.key,
    required this.foodItem,
    this.userPosition,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final RatingService _ratingService = RatingService();
  final DatabaseService _databaseService = DatabaseService();
  double _averageRating = 0.0;
  int _ratingCount = 0;
  bool _isLoadingRating = true;
  bool _isReserved = false;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _isReserved = widget.foodItem.isReserved;
    _loadRatings();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadRatings() async {
    final average = await _ratingService.getAverageRating(widget.foodItem.id);
    final count = await _ratingService.getRatingCount(widget.foodItem.id);
    if (mounted) {
      setState(() {
        _averageRating = average;
        _ratingCount = count;
        _isLoadingRating = false;
      });
    }
  }

  Future<void> _reserveFoodItem() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kirjaudu sisään varataksesi'), backgroundColor: Colors.orange),
      );
      return;
    }

    // ESTÄ OMAN VARAUS
    if (widget.foodItem.userId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Et voi varata omaa ilmoitustasi!'), backgroundColor: Colors.red),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Varaa ruoka'),
        content: const Text('Haluatko varmasti varata tämän ruoan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Peruuta')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Varaa')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.reserveFoodItem(widget.foodItem.id, user.uid);
        if (mounted) {
          setState(() {
            _isReserved = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ruoka varattu!'), backgroundColor: Color(0xFF388E3C)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ErrorHelper.getUserFriendlyErrorMessage(e)), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _deleteFoodItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Poista ilmoitus'),
        content: const Text('Haluatko varmasti poistaa tämän ilmoituksen? Tätä toimintoa ei voi perua.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Peruuta'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Poista'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.deleteFoodItem(widget.foodItem.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ilmoitus poistettu'), backgroundColor: Colors.grey),
          );
          Navigator.pop(context); // Palaa takaisin listaan
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ErrorHelper.getUserFriendlyErrorMessage(e)), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // --- MUOKKAUS-NAVIGOINTI ---
  void _editFoodItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFoodScreen(foodItem: widget.foodItem),
      ),
    );
  }

  Future<void> _showRatingDialog() async {
    int selectedRating = 5;
    final commentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Arvostele ilmoitus'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFF6F00),
                      size: 40,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        selectedRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Kommentti (valinnainen)',
                  hintText: 'Esim. "Haki ajoissa", "Ruoka oli hyvää"',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Peruuta'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _ratingService.addRating(
                    widget.foodItem.id,
                    selectedRating,
                    commentController.text,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    _loadRatings();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Arvostelu lisätty!'),
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    final errorMessage = ErrorHelper.getUserFriendlyErrorMessage(e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Lähetä'),
            ),
          ],
        ),
      ),
    );
  }

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

  String? _calculateDistance() {
    if (widget.userPosition == null) return null;
    
    final distance = Geolocator.distanceBetween(
      widget.userPosition!.latitude,
      widget.userPosition!.longitude,
      widget.foodItem.latitude,
      widget.foodItem.longitude,
    );
    
    if (distance < 1000) {
      return '${distance.toInt()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance();
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser != null && widget.foodItem.userId == currentUser.uid;
    final canChat = currentUser != null && !isOwner;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ilmoituksen tiedot'),
        actions: [
          if (canChat)
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                      otherUserId: widget.foodItem.userId!,
                      otherUserName: widget.foodItem.userName,
                      otherUserProfileImageUrl: widget.foodItem.userProfileImageUrl,
                    )));
              },
            ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Muokkaa ilmoitusta',
              onPressed: _editFoodItem,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kuvien carousel
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: widget.foodItem.allImages.length,
                    itemBuilder: (context, index) {
                      final imageUrl = widget.foodItem.allImages[index];
                      return Hero(
                        tag: 'food_image_${widget.foodItem.id}_$index',
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 300,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 300,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Kuvien indikaattorit
                if (widget.foodItem.allImages.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.foodItem.allImages.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Sisältö
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Merkit (Kategoria, hinta, varattu, arvostelu)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          widget.foodItem.category.displayName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                      if (widget.foodItem.quantity != null && widget.foodItem.quantityUnit != null)
                        Chip(
                          label: Text(
                            '${widget.foodItem.quantity!.toStringAsFixed(widget.foodItem.quantity! % 1 == 0 ? 0 : 1)} ${widget.foodItem.quantityUnit}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: const Color(0xFF388E3C).withOpacity(0.1),
                          labelStyle: const TextStyle(color: Color(0xFF388E3C)),
                        ),
                      if (widget.foodItem.price != null)
                        Chip(
                          avatar: const Icon(
                            Icons.euro,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: Text(
                            '${widget.foodItem.price!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: const Color(0xFFFF8F00),
                        )
                      else
                        Chip(
                          avatar: const Icon(
                            Icons.free_breakfast,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            'Ilmainen',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: const Color(0xFF388E3C),
                        ),
                      if (_isReserved || widget.foodItem.isReserved)
                        Chip(
                          avatar: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            'Varattu',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      if (!_isLoadingRating && _ratingCount > 0)
                        Chip(
                          avatar: const Icon(
                            Icons.star,
                            color: Color(0xFFFF6F00),
                            size: 18,
                          ),
                          label: Text(
                            '${_averageRating.toStringAsFixed(1)} ($_ratingCount)',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFFFF6F00),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Otsikko
                  Text(
                    widget.foodItem.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Käyttäjän tiedot
                  if (widget.foodItem.userName != null || widget.foodItem.userProfileImageUrl != null)
                    Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: widget.foodItem.userProfileImageUrl != null
                            ? CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  widget.foodItem.userProfileImageUrl!,
                                ),
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                        title: Text(
                          widget.foodItem.userName ?? 'Tuntematon käyttäjä',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Jakaja'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  
                  // Kuvaus
                  Text(
                    widget.foodItem.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Tiedot
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.access_time,
                          'Julkaistu',
                          _formatTimestamp(widget.foodItem.timestamp),
                        ),
                        if (distance != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.location_on,
                            'Etäisyys',
                            distance,
                          ),
                        ],
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.category,
                          'Kategoria',
                          widget.foodItem.category.displayName,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // JOS OMISTAJA -> MUOKKAA JA POISTA
                  if (isOwner) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _editFoodItem,
                        icon: const Icon(Icons.edit),
                        label: const Text('Muokkaa ilmoitusta'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _deleteFoodItem,
                        icon: const Icon(Icons.delete),
                        label: const Text('Poista ilmoitus'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ]
                  // JOS EI OMISTAJA JA EI VARATTU -> VARAA-NAPPI
                  else if (!_isReserved && !widget.foodItem.isReserved)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _reserveFoodItem,
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Varaa ruoka'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFFF8F00),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    )
                  else if (_isReserved || widget.foodItem.isReserved)
                    // JOS VARATTU
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Text(
                        'Tämä tuote on jo varattu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
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