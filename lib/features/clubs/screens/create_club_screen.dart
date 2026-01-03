/// Create Club Screen
///
/// Form to create a new gaming club
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clubroyale/core/utils/error_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clubroyale/features/clubs/club_model.dart';
import 'package:clubroyale/features/clubs/club_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

class CreateClubScreen extends ConsumerStatefulWidget {
  const CreateClubScreen({super.key});

  @override
  ConsumerState<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends ConsumerState<CreateClubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  ClubPrivacy _privacy = ClubPrivacy.public;
  final Set<String> _gameTypes = {'marriage'};
  bool _isLoading = false;
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Club')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Club avatar picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : null,
                        child: _imageFile == null
                            ? const Icon(Icons.groups, size: 48)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 18,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Club Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Club Name',
                  hintText: 'e.g., Royal Card Masters',
                  prefixIcon: Icon(Icons.groups),
                ),
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Required';
                  if (v!.length < 3) return 'At least 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What is your club about?',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Privacy (Keep existing)
              Text('Privacy', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<ClubPrivacy>(
                segments: const [
                  ButtonSegment(
                    value: ClubPrivacy.public,
                    label: Text('Public'),
                    icon: Icon(Icons.public),
                  ),
                  ButtonSegment(
                    value: ClubPrivacy.private,
                    label: Text('Private'),
                    icon: Icon(Icons.lock),
                  ),
                ],
                selected: {_privacy},
                onSelectionChanged: (s) => setState(() => _privacy = s.first),
              ),
              const SizedBox(height: 8),

              const SizedBox(height: 24),

              // Game Types (Keep existing)
              Text(
                'Games Played',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Marriage'),
                    selected: _gameTypes.contains('marriage'),
                    onSelected: (s) => setState(() {
                      s
                          ? _gameTypes.add('marriage')
                          : _gameTypes.remove('marriage');
                    }),
                  ),
                  FilterChip(
                    label: const Text('Teen Patti'),
                    selected: _gameTypes.contains('teen_patti'),
                    onSelected: (s) => setState(() {
                      s
                          ? _gameTypes.add('teen_patti')
                          : _gameTypes.remove('teen_patti');
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading ? null : _createClub,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Club'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createClub() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = ref.read(authServiceProvider);
      final user = auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      String? avatarUrl;
      if (_imageFile != null) {
        avatarUrl = await ref
            .read(clubServiceProvider)
            .uploadClubAvatar(_imageFile!);
      }

      await ref
          .read(clubServiceProvider)
          .createClub(
            ownerId: user.uid,
            ownerName: user.displayName ?? 'Host',
            name: _nameController.text,
            description: _descriptionController.text,
            privacy: _privacy,
            gameTypes: _gameTypes.toList(),
            avatarUrl: avatarUrl,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Club created!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHelper.getFriendlyMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
