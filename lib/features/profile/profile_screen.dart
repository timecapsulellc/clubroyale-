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
import 'package:clubroyale/core/widgets/skeleton_loading.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TabController _tabController;
  XFile? _image;
  Uint8List? _imageBytes;
  bool _isEditing = false;

  // Theme State
  String _selectedTheme = 'Gold';
  String? _generatedAvatarUrl; // Holds the AI generated URL temporarily
  final Map<String, List<Color>> _themeColors = {
    'Gold': [const Color(0xFFD4AF37), const Color(0xFFF7E7CE)],
    'Neo': [Colors.cyan, Colors.blueAccent],
    'Purple': [Colors.purpleAccent, const Color(0xFF7c3aed)],
    'Pink': [Colors.pinkAccent, Colors.redAccent],
    'Fire': [Colors.orange, Colors.deepOrange],
  };

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

  // Initial Data Load
  void _loadUserProfile(UserProfile user) {
    if (_displayNameController.text.isEmpty) {
      _displayNameController.text = user.displayName;
    }
    if (_selectedTheme == 'Gold' && user.profileTheme != null) {
      _selectedTheme = user.profileTheme!;
    }
  }

  Future<void> _showAvatarOptions() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2d1b4e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Update Profile Picture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text(
                'Upload from Gallery (PNG, JPG, GIF)',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.auto_awesome,
                color: ClubRoyaleTheme.champagne,
              ),
              title: const Text(
                'Generate AI Avatar',
                style: TextStyle(
                  color: ClubRoyaleTheme.champagne,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Try Nano Banana Pro styles',
                style: TextStyle(color: Colors.white54),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _showAiGeneratorDialog();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    ); // Supports GIFs on most OS
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _image = pickedFile;
        _imageBytes = bytes;
        _generatedAvatarUrl = null; // Clear AI url if picking new image
      });
    }
  }

  void _showAiGeneratorDialog() {
    final promptController = TextEditingController();
    bool isGenerating = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF1a0a2e),
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: ClubRoyaleTheme.gold),
              SizedBox(width: 8),
              Text('AI Avatar Studio', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Describe your dream avatar. First generation is FREE!',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: promptController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Cyberpunk panda with sunglasses',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isGenerating)
                const Column(
                  children: [
                    CircularProgressIndicator(color: ClubRoyaleTheme.gold),
                    SizedBox(height: 12),
                    Text(
                      'Creating magic...',
                      style: TextStyle(color: ClubRoyaleTheme.gold),
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ClubRoyaleTheme.gold,
              ),
              onPressed: isGenerating
                  ? null
                  : () async {
                      setStateDialog(() => isGenerating = true);

                      // MOCK GENERATION
                      await Future.delayed(const Duration(seconds: 2));

                      // Use a seeded picsum image to simulate AI result
                      final seed = promptController.text.hashCode;
                      final mockUrl =
                          'https://picsum.photos/seed/$seed/400/400';

                      // Fetch bytes for preview
                      // In real app, we'd define this URL as success.
                      // Here we can't easily fetch bytes from URL to _imageBytes without http package call.
                      // For 'Avatar URL', we usually set the URL directly in profile.
                      // To preview it in the UI, we need to handle "URL mode" vs "Byte mode".
                      // Simplification: We will just set the URL on SAVE, but for preview we rely on a temp var.

                      if (mounted) {
                        setState(() {
                          _generatedAvatarUrl = mockUrl;
                          _imageBytes = null; // Clear local bytes
                          _image = null;
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '✨ Avatar Generated! Save profile to apply.',
                            ),
                          ),
                        );
                      }
                    },
              child: const Text('Generate (Free)'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _uploadAvatar(String userId) async {
    if (_imageBytes == null) return '';
    final storageRef = FirebaseStorage.instance.ref().child('avatars/$userId');
    // Set content type for GIFs if detected, though Firebase usually auto-detects
    final metadata = SettableMetadata(
      contentType: 'image/png',
    ); // Defaulting for now
    final uploadTask = storageRef.putData(_imageBytes!, metadata);
    final snapshot = await uploadTask.whenComplete(() {});
    return snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final profileAsync = ref.watch(myProfileProvider);

    if (user == null || (profileAsync.isLoading && !profileAsync.hasValue)) {
      return const SkeletonProfile();
    }

    // Initialize theme from profile once loaded
    // We use a post-frame callback or just check if we are in init state (not editing yet)
    // Actually, we can just let _selectedTheme be updated if we haven't touched it?
    // It's simpler to set it when entering Edit mode.

    return Scaffold(
      backgroundColor: CasinoColors.darkPurple,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: ClubRoyaleTheme.gold,
            ),
            onPressed: () async {
              if (_isEditing) {
                // SAVE LOGIC
                if (_displayNameController.text.isNotEmpty) {
                  try {
                    String? avatarUrl = _generatedAvatarUrl;
                    if (_imageBytes != null) {
                      avatarUrl = await _uploadAvatar(user.uid);
                    }

                    // Get current profile to preserve stats
                    final currentProfile = profileAsync.value;

                    final updatedProfile =
                        currentProfile?.copyWith(
                          displayName: _displayNameController.text,
                          avatarUrl: avatarUrl ?? currentProfile.avatarUrl,
                          profileTheme: _selectedTheme,
                        ) ??
                        UserProfile(
                          id: user.uid,
                          displayName: _displayNameController.text,
                          avatarUrl: avatarUrl,
                          profileTheme: _selectedTheme,
                          // Defaults for new profile
                          createdAt: DateTime.now(),
                        );

                    await ref
                        .read(profileServiceProvider)
                        .updateProfile(updatedProfile);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating profile: $e')),
                      );
                    }
                  }
                }
                setState(() => _isEditing = false);
              } else {
                // ENTER EDIT MODE
                setState(() {
                  _isEditing = true;
                  // Sync theme from profile
                  if (profileAsync.value?.profileTheme != null) {
                    _selectedTheme = profileAsync.value!.profileTheme!;
                  }
                });
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
              const SizedBox(height: 20),

              // 1. Profile Header with Theme Effect & Data
              Center(
                child: GestureDetector(
                  onTap: _isEditing ? _showAvatarOptions : null,
                  child: Stack(
                    children: [
                      // Loading indicator if profile loading
                      if (profileAsync.isLoading)
                        const Positioned.fill(
                          child: CircularProgressIndicator(),
                        ),

                      // Glowing Theme Ring
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors:
                                _themeColors[_selectedTheme] ??
                                _themeColors['Gold']!,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (_themeColors[_selectedTheme] ??
                                          _themeColors['Gold']!)
                                      .first
                                      .withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black26,
                          backgroundImage: _imageBytes != null
                              ? MemoryImage(_imageBytes!)
                              : (user.photoURL != null
                                    ? NetworkImage(user.photoURL!)
                                    : null),
                          // Fallback to letters
                          child: (user.photoURL == null && _imageBytes == null)
                              ? Text(
                                  user.displayName?.isNotEmpty == true
                                      ? user.displayName![0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 40,
                                    color:
                                        (_themeColors[_selectedTheme] ??
                                                _themeColors['Gold']!)
                                            .first,
                                  ),
                                )
                              : null,
                        ),
                      ),

                      // Edit Badge
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  (_themeColors[_selectedTheme] ??
                                          _themeColors['Gold']!)
                                      .first,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.black,
                            ),
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter Name',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: ClubRoyaleTheme.gold),
                      ),
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

              // THEME SELECTOR (Only in Edit Mode)
              if (_isEditing) ...[
                const SizedBox(height: 24),
                const Text(
                  'Choose Profile Theme',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _themeColors.entries.map((entry) {
                      final isSelected = _selectedTheme == entry.key;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTheme = entry.key),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: entry.value),
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: entry.value.first.withValues(
                                          alpha: 0.6,
                                        ),
                                        blurRadius: 12,
                                      ),
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 10), // Reduced spacing
              Text(
                'Member since ${_formatDate(user.metadata.creationTime)}',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),

              // ... rest of the file ... (Stats grid etc)
              const SizedBox(height: 24),

              // 2. Stats Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Games',
                        value: '${profileAsync.value?.gamesPlayed ?? 0}',
                        icon: Icons.sports_esports,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Wins',
                        value: '${profileAsync.value?.gamesWon ?? 0}',
                        icon: Icons.emoji_events,
                        isHighlight: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Win Rate',
                        value:
                            '${((profileAsync.value?.winRate ?? 0) * 100).toStringAsFixed(1)}%',
                        icon: Icons.pie_chart,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              // 3. Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
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
                                  builder: (context) =>
                                      AllAchievementsScreen(userId: user.uid),
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

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isHighlight
            ? ClubRoyaleTheme.gold.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight
              ? ClubRoyaleTheme.gold.withValues(alpha: 0.5)
              : Colors.white10,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isHighlight ? ClubRoyaleTheme.gold : Colors.white54,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isHighlight ? ClubRoyaleTheme.gold : Colors.white,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.white54)),
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

  const _CustomizationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
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
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: onTap,
      ),
    );
  }
}
