import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/food_item.dart';
import '../services/user_service.dart';
import '../services/database_service.dart';
import 'home_screen.dart'; // KORJAUS: Vaihdettu LoginScreen -> HomeScreen
import 'edit_profile_screen.dart';
import 'food_list_screen.dart';
import 'settings_screen.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final UserService _userService = UserService();
  final DatabaseService _databaseService = DatabaseService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  late TabController _tabController;
  late AnimationController _avatarController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _avatarController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _avatarController.dispose();
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

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      // ⭐ APPLE COMPLIANCE: Vie HomeScreen:iin, ei LoginScreen:iin
      // Käyttäjä voi jatkaa selaamista vieraana
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_currentUser == null) {
      return Center(child: Text(l10n.loginToViewProfile));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProfile),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              } else if (value == 'logout') {
                _signOut();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(l10n.settings),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(l10n.logout),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // KÄYTTÄJÄTIEDOT - UUSITTU HEADER
            FutureBuilder<UserModel?>(
              future: _userService.getUser(_currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final user = snapshot.data;
                final String displayName = (user?.name?.isNotEmpty == true)
                    ? user!.name!
                    : l10n.anonymous;
                final String initial =
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        user?.levelColor.withValues(alpha: 0.2) ??
                            Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.1),
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Column(
                    children: [
                      // Avatar with Pulse
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _avatarController,
                            builder: (context, child) {
                              return Container(
                                width: 100 + (_avatarController.value * 10),
                                height: 100 + (_avatarController.value * 10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: user?.levelColor.withValues(
                                            alpha: 0.5 -
                                                (_avatarController.value *
                                                    0.3)) ??
                                        Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Theme.of(context).cardTheme.color,
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: user?.levelColor ?? Colors.grey,
                              backgroundImage: user?.profileImageUrl != null
                                  ? NetworkImage(user!.profileImageUrl!)
                                  : null,
                              child: user?.profileImageUrl == null
                                  ? Text(
                                      initial,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          // Edit button badge
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: user != null
                                  ? () => _navigateToEditProfile(user)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.edit,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: user?.levelColor.withValues(alpha: 0.1) ??
                              Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(user?.levelIcon,
                                size: 14,
                                color: user?.levelColor ?? Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _getUserLevelName(context, user),
                              style: TextStyle(
                                color: user?.levelColor ?? Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (user != null) _buildStatsCard(context, user),
                    ],
                  ),
                );
              },
            ),

            // MENU OPTIONS
            Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<List<FoodItem>>(
                stream: _databaseService.getFoodItemsStream(),
                builder: (context, snapshot) {
                  final allItems = snapshot.data ?? [];

                  // Calculate counts
                  final myItemsCount = allItems
                      .where((item) => item.userId == _currentUser!.uid)
                      .length;

                  final myReservationsCount = allItems
                      .where((item) =>
                          item.reservedByUserId == _currentUser!.uid &&
                          item.status == ReservationStatus.reserved)
                      .length;

                  return StreamBuilder<UserModel?>(
                      stream: _userService.getUserStream(_currentUser!.uid),
                      builder: (context, userSnapshot) {
                        final favIds =
                            userSnapshot.data?.favorites.toSet() ?? {};
                        final favoritesCount = allItems
                            .where((item) => favIds.contains(item.id))
                            .length;

                        return Column(
                          children: [
                            _buildMenuOption(
                              context,
                              title: l10n.myListings,
                              icon: Icons.store,
                              count: myItemsCount,
                              color: Colors.blue,
                              onTap: () {
                                final myItems = allItems
                                    .where((item) =>
                                        item.userId == _currentUser!.uid)
                                    .toList();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodListScreen(
                                      title: l10n.myListings,
                                      items: myItems,
                                      emptyMessage: l10n.noListings,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildMenuOption(
                              context,
                              title: l10n.myReservations,
                              icon: Icons.shopping_bag,
                              count: myReservationsCount,
                              color: Colors.orange,
                              onTap: () {
                                final myReservations = allItems
                                    .where((item) =>
                                        item.reservedByUserId ==
                                            _currentUser!.uid &&
                                        item.status ==
                                            ReservationStatus.reserved)
                                    .toList();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodListScreen(
                                      title: l10n.myReservations,
                                      items: myReservations,
                                      emptyMessage: l10n.noReservations,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildMenuOption(
                              context,
                              title: l10n.favorites,
                              icon: Icons.favorite,
                              count: favoritesCount,
                              color: Colors.red,
                              onTap: () {
                                final myFavorites = allItems
                                    .where((item) => favIds.contains(item.id))
                                    .toList();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodListScreen(
                                      title: l10n.favorites,
                                      items: myFavorites,
                                      emptyMessage: l10n.noFavorites,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, UserModel user) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              user.levelColor.withValues(alpha: 0.1),
              Theme.of(context).cardTheme.color ?? Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Level Badge
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: user.levelColor.withValues(alpha: 0.2),
                  child: Icon(user.levelIcon, color: user.levelColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getUserLevelName(context, user),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: user.levelColor,
                        ),
                      ),
                      Text(
                        user.totalShared < 10
                            ? l10n.sharedPortions(user.totalShared)
                            : l10n.maxLevelReached,
                        style: TextStyle(
                            fontSize: 13,
                            color:
                                Theme.of(context).textTheme.bodySmall?.color),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Progress bar (hide if max level)
            if (user.totalShared < 10) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.progressToNextLevel,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        user.totalShared < 5
                            ? '${user.totalShared}/5'
                            : '${user.totalShared - 5}/5',
                        style: TextStyle(
                          fontSize: 11,
                          color: user.levelColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: user.levelProgress,
                      backgroundColor:
                          Theme.of(context).dividerColor.withValues(alpha: 0.2),
                      color: user.levelColor,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),
            Container(
              height: 1,
              color: Theme.of(context).dividerColor,
            ),
            const SizedBox(height: 16),

            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  l10n.statShared,
                  user.totalShared.toString(),
                  Icons.restaurant,
                ),
                _buildStatItem(
                  l10n.statRating,
                  user.totalRatings > 0
                      ? '⭐ ${user.averageRating.toStringAsFixed(1)}'
                      : l10n.notYet,
                  Icons.star_outline,
                ),
                _buildStatItem(
                  l10n.statReviews,
                  user.totalRatings.toString(),
                  Icons.rate_review,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon,
            size: 20,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color),
        ),
      ],
    );
  }

  String _getUserLevelName(BuildContext context, UserModel? user) {
    final l10n = AppLocalizations.of(context)!;
    if (user == null) return l10n.userLevelBeginner;
    if (user.totalShared < 5) return l10n.userLevelBeginner;
    if (user.totalShared < 10) return l10n.userLevelActive;
    return l10n.userLevelVeteran;
  }
}
