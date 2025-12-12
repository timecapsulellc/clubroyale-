import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:clubroyale/core/config/club_royale_theme.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../auth/auth_service.dart';
import '../wallet/diamond_balance_widget.dart';
import '../store/ui/theme_store_bottom_sheet.dart';
import 'profile_service.dart';
import 'user_profile.dart';
import 'widgets/badges_grid.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TabController _tabController;
  XFile? _image;
  Uint8List? _imageBytes;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _image = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<String> _uploadAvatar(String userId) async {
    if (_imageBytes == null) return '';
    final storageRef = FirebaseStorage.instance.ref().child('avatars/$userId');
    final uploadTask = storageRef.putData(_imageBytes!);
    final snapshot = await uploadTask.whenComplete(() {});
    return snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    // We would typically fetch full profile stats here
    
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Pre-fill controller if not editing
    if (!_isEditing && _displayNameController.text.isEmpty) {
      _displayNameController.text = user.displayName ?? '';
    }

    return Scaffold(
      backgroundColor: CasinoColors.darkPurple,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading:  IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/'), // Correct nav back to home
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit, color: ClubRoyaleTheme.gold),
            onPressed: () async {
              if (_isEditing) {
                // Save logic
                if (_displayNameController.text.isNotEmpty) {
                    String? avatarUrl;
                    if (_imageBytes != null) {
                      avatarUrl = await _uploadAvatar(user.uid);
                    }
                    final profile = UserProfile(
                      id: user.uid,
                      displayName: _displayNameController.text,
                      avatarUrl: avatarUrl,
                    );
                    await ref.read(profileServiceProvider).updateProfile(profile);
                }
                setState(() => _isEditing = false);
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
          const SizedBox(width: 8),
          const DiamondBalanceBadge(),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [CasinoColors.deepPurple, CasinoColors.darkPurple],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Profile Header
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _isEditing ? _pickImage : null,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ClubRoyaleTheme.gold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: ClubRoyaleTheme.gold.withOpacity(0.3),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black26,
                          backgroundImage: _imageBytes != null 
                              ? MemoryImage(_imageBytes!) 
                              : (user.photoURL != null ? NetworkImage(user.photoURL!) : null),
                          child: (user.photoURL == null && _imageBytes == null)
                              ? Text(
                                  user.displayName?.isNotEmpty == true ? user.displayName![0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 40, color: ClubRoyaleTheme.gold),
                                )
                              : null,
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: ClubRoyaleTheme.gold,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 16),
              
              // Name Field
              if (_isEditing)
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 40),
                   child: TextField(
                     controller: _displayNameController,
                     textAlign: TextAlign.center,
                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                     decoration: const InputDecoration(
                       hintText: 'Enter Name',
                       hintStyle: TextStyle(color: Colors.white54),
                       border: UnderlineInputBorder(borderSide: BorderSide(color: ClubRoyaleTheme.gold)),
                       enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                       focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ClubRoyaleTheme.gold)),
                     ),
                   ),
                 )
              else
                Text(
                  user.displayName ?? 'Player',
                  style: const TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn().slideY(begin: 0.2),

              Text(
                'Member since ${_formatDate(user.metadata.creationTime)}',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),

              const SizedBox(height: 24),

              // 2. Stats Grid (Mock data for display if service doesn't provide it yet)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: _StatCard(label: 'Games', value: '0', icon: Icons.sports_esports)), // TODO: Connect to real stats
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: 'Wins', value: '0', icon: Icons.emoji_events, isHighlight: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: 'Win Rate', value: '0%', icon: Icons.pie_chart)),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              // 3. Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: ClubRoyaleTheme.gold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Achievements'),
                    Tab(text: 'Customizations'),
                  ],
                ),
              ),

              // 4. Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Achievements Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          BadgesGrid(
                           userId: user.uid,
                           onSeeAllTap: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => AllAchievementsScreen(userId: user.uid),
                               ),
                             );
                           },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    
                    // Customizations Tab
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _CustomizationTile(
                          icon: Icons.palette,
                          title: 'Table Theme',
                          subtitle: 'Classic Green',
                          onTap: () => showThemeStoreBottomSheet(context),
                        ),
                         _CustomizationTile(
                          icon: Icons.style,
                          title: 'Card Deck',
                          subtitle: 'Royal Gold',
                          onTap: () => showThemeStoreBottomSheet(context),
                        ),
                         _CustomizationTile(
                          icon: Icons.emoji_emotions,
                          title: 'Chat Stickers',
                          subtitle: 'Default Pack',
                          onTap: () {}, // Future feature
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlight;

  const _StatCard({required this.label, required this.value, required this.icon, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isHighlight ? ClubRoyaleTheme.gold.withOpacity(0.15) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight ? ClubRoyaleTheme.gold.withOpacity(0.5) : Colors.white10,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: isHighlight ? ClubRoyaleTheme.gold : Colors.white54, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isHighlight ? ClubRoyaleTheme.gold : Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _CustomizationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CustomizationTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ClubRoyaleTheme.champagne),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: onTap,
      ),
    );
  }
}
