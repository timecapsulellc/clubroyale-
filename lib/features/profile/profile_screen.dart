
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:io'; // Removed for web compatibility

import '../auth/auth_service.dart';
import '../wallet/diamond_balance_widget.dart';
import '../store/ui/theme_store_bottom_sheet.dart';
import 'profile_service.dart';
import 'user_profile.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  XFile? _image;
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _displayNameController.dispose();
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
    // Use putData instead of putFile for web compatibility
    final uploadTask = storageRef.putData(_imageBytes!);
    final snapshot = await uploadTask.whenComplete(() {});
    return snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final profileService = ref.watch(profileServiceProvider);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: const [
          DiamondBalanceBadge(),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  // Use MemoryImage which works on usage both platforms without dart:io
                  backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                  child: _imageBytes == null ? const Icon(Icons.add_a_photo, size: 50) : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (user != null) {
                      String? avatarUrl;
                      if (_imageBytes != null) {
                        avatarUrl = await _uploadAvatar(user.uid);
                      }
                      final profile = UserProfile(
                        id: user.uid,
                        displayName: _displayNameController.text,
                        avatarUrl: avatarUrl,
                      );
                      await profileService.updateProfile(profile);
                      if (context.mounted) {
                        context.pop();
                      }
                    }
                  }
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 32),
              // Theme Store Section
              const Divider(),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.palette_outlined, color: Colors.amber.shade700),
                ),
                title: const Text('Customize Table', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Change themes and card skins'),
                trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600),
                onTap: () {
                  // Import and show theme store bottom sheet
                  showThemeStoreBottomSheet(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
