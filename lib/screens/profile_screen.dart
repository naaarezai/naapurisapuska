import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/food_item.dart';
import '../services/user_service.dart';
import '../services/database_service.dart';
import '../services/favorite_service.dart';
import '../widgets/food_card.dart';
import '../screens/login_screen.dart';
import 'edit_profile_screen.dart';
import 'food_detail_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final DatabaseService _databaseService = DatabaseService();
  final FavoriteService _favoriteService = FavoriteService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToEditProfile(UserModel user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: user),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  // --- UUSI: Uloskirjautuminen omana funktionaan ---
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // --- TILIN POISTAMINEN ---
  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Poista tili?'),
        content: const Text('Tämä toiminto poistaa tilisi ja kaikki ilmoituksesi pysyvästi. Tätä ei voi perua.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Peruuta'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Poista tili'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _userService.deleteAccount();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Virhe tilin poistossa. Kirjaudu uudelleen ja yritä heti.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Center(child: Text("Kirjaudu sisään nähdäksesi profiilin"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oma Profiili'),
        // --- UUSI: Valikko yläkulmassa ---
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _signOut();
              } else if (value == 'delete') {
                _deleteAccount();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Kirjaudu ulos'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text('Poista tili', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // KÄYTTÄJÄTIEDOT
          FutureBuilder<UserModel?>(
            future: _userService.getUser(_currentUser!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
              }
              final user = snapshot.data;
              final String displayName = (user?.name?.isNotEmpty == true) ? user!.name! : 'Nimetön';
              final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

              return Container(
                padding: const EdgeInsets.all(20),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: user?.profileImageUrl != null ? NetworkImage(user!.profileImageUrl!) : null,
                          child: user?.profileImageUrl == null ? Text(initial, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)) : null,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(user?.phoneNumber ?? '', style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: user != null ? () => _navigateToEditProfile(user) : null,
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text("Muokkaa tietoja"),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    // "Poista tili" -nappi on poistettu tästä kohtaa!
                  ],
                ),
              );
            },
          ),

          // TABIT
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(icon: Icon(Icons.store), text: "Omat"),
              Tab(icon: Icon(Icons.shopping_bag), text: "Varaukset"),
              Tab(icon: Icon(Icons.favorite), text: "Suosikit"),
            ],
          ),

          // LISTAT
          Expanded(
            child: StreamBuilder<List<FoodItem>>(
              stream: _databaseService.getFoodItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Virhe: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                
                final allItems = snapshot.data ?? [];
                final myItems = allItems.where((item) => item.userId == _currentUser!.uid).toList();
                final myReservations = allItems.where((item) => item.isReserved == true && item.reservedByUserId == _currentUser!.uid).toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFoodList(myItems, "Et ole lisännyt ilmoituksia."),
                    _buildFoodList(myReservations, "Et ole varannut mitään."),
                    StreamBuilder<List<String>>(
                      stream: _favoriteService.getFavoriteIdsStream(),
                      builder: (context, favSnapshot) {
                        final favIds = favSnapshot.data ?? [];
                        final myFavorites = allItems.where((item) => favIds.contains(item.id)).toList();
                        return _buildFoodList(myFavorites, "Ei suosikkeja.");
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(List<FoodItem> items, String emptyMessage) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300), 
            const SizedBox(height: 16), 
            Text(emptyMessage, style: const TextStyle(color: Colors.grey, fontSize: 16))
          ]
        )
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8), 
      itemCount: items.length, 
      itemBuilder: (context, index) {
        return FoodCard(foodItem: items[index]);
      }
    );
  }
}