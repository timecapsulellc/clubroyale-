import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clubroyale/features/stories/models/story.dart';
import 'package:clubroyale/features/stories/services/story_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Screen for creating and posting a new story
class StoryCreatorScreen extends ConsumerStatefulWidget {
  const StoryCreatorScreen({super.key});

  @override
  ConsumerState<StoryCreatorScreen> createState() => _StoryCreatorScreenState();
}

class _StoryCreatorScreenState extends ConsumerState<StoryCreatorScreen> {
  Uint8List? _selectedMediaBytes;
  StoryMediaType _mediaType = StoryMediaType.photo;
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _textOverlayController = TextEditingController();
  Color _textColor = Colors.white;
  bool _isUploading = false;
  bool _showTextOverlay = false;
  String? _errorMessage;

  final List<Color> _colorOptions = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.yellow,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMediaPicker();
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _textOverlayController.dispose();
    super.dispose();
  }

  Future<void> _showMediaPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Create Story',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a photo or select from gallery',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              // Gallery option first
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.purple),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select an existing photo'),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              // Camera option - uses pickImage with camera source
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text('Use Camera'),
                subtitle: Text(
                  kIsWeb ? 'Opens camera capture dialog' : 'Take a new photo',
                ),
                onTap: () => Navigator.pop(context, 'camera_photo'),
              ),
              // Video option (mobile only - web video capture is complex)
              if (!kIsWeb)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.videocam, color: Colors.red),
                  ),
                  title: const Text('Record Video'),
                  subtitle: const Text('Record up to 30 seconds'),
                  onTap: () => Navigator.pop(context, 'camera_video'),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    if (result == null && mounted) {
      context.pop();
      return;
    }

    await _pickMedia(result!);
  }

  Future<void> _pickMedia(String source) async {
    final picker = ImagePicker();
    XFile? file;

    setState(() {
      _errorMessage = null;
    });

    try {
      switch (source) {
        case 'camera_photo':
          // Use ImageSource.camera - on web this uses HTML input with capture attribute
          file = await picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1080,
            maxHeight: 1920,
            imageQuality: 85,
            preferredCameraDevice: CameraDevice.rear,
          );
          _mediaType = StoryMediaType.photo;
          break;
        case 'camera_video':
          file = await picker.pickVideo(
            source: ImageSource.camera,
            maxDuration: const Duration(seconds: 30),
            preferredCameraDevice: CameraDevice.rear,
          );
          _mediaType = StoryMediaType.video;
          break;
        case 'gallery':
          file = await picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1080,
            maxHeight: 1920,
            imageQuality: 85,
          );
          _mediaType = StoryMediaType.photo;
          break;
      }

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedMediaBytes = bytes;
        });
      } else if (mounted) {
        _showPickerOrGoBack();
      }
    } catch (e) {
      String errorMsg = 'Failed to access media';

      // Check for common error types
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('camera') ||
          errorString.contains('notallowederror') ||
          errorString.contains('permission')) {
        if (kIsWeb) {
          errorMsg =
              'Camera not available on this browser. Please use "Choose from Gallery" instead, or try on a mobile device.';
        } else {
          errorMsg =
              'Camera access denied. Please enable camera permission in Settings.';
        }
      } else if (errorString.contains('notfounderror')) {
        errorMsg =
            'No camera found on this device. Please use "Choose from Gallery" instead.';
      }

      setState(() {
        _errorMessage = errorMsg;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Use Gallery',
              textColor: Colors.white,
              onPressed: () => _pickMedia('gallery'),
            ),
          ),
        );
      }
    }
  }

  void _showPickerOrGoBack() {
    if (_selectedMediaBytes == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No media selected'),
          content: const Text('Would you like to try again?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                this.context.pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showMediaPicker();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _postStory() async {
    if (_selectedMediaBytes == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await ref
          .read(storyServiceProvider)
          .createStory(
            mediaBytes: _selectedMediaBytes!,
            mediaType: _mediaType,
            caption: _captionController.text.isNotEmpty
                ? _captionController.text
                : null,
            textOverlay:
                _showTextOverlay && _textOverlayController.text.isNotEmpty
                ? _textOverlayController.text
                : null,
            textColor: _showTextOverlay
                ? _textColor.value.toRadixString(16).substring(2)
                : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story posted!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post story: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _selectedMediaBytes == null
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            )
          : null,
      body: _selectedMediaBytes == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickMedia('gallery'),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Use Gallery'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _showMediaPicker,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text(
                            'Try Again',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                // Preview
                _mediaType == StoryMediaType.video
                    ? Container(
                        color: Colors.black,
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.videocam,
                                size: 80,
                                color: Colors.white54,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Video selected',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Image.memory(
                        _selectedMediaBytes!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),

                // Text overlay
                if (_showTextOverlay)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _textOverlayController,
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(blurRadius: 4, color: Colors.black54),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Type your text...',
                          hintStyle: TextStyle(
                            color: _textColor.withValues(alpha: 0.5),
                            fontSize: 24,
                          ),
                          border: InputBorder.none,
                        ),
                        autofocus: true,
                      ),
                    ).animate().fadeIn(duration: 200.ms),
                  ),

                // Top bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 8,
                      right: 8,
                      bottom: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            _showTextOverlay
                                ? Icons.text_fields
                                : Icons.text_fields_outlined,
                            color: _showTextOverlay
                                ? colorScheme.primary
                                : Colors.white,
                          ),
                          onPressed: () => setState(
                            () => _showTextOverlay = !_showTextOverlay,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: _showMediaPicker,
                        ),
                      ],
                    ),
                  ),
                ),

                // Color picker
                if (_showTextOverlay)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 60,
                    left: 0,
                    right: 0,
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _colorOptions.length,
                      itemBuilder: (context, index) {
                        final color = _colorOptions[index];
                        final isSelected = color == _textColor;
                        return GestureDetector(
                          onTap: () => setState(() => _textColor = color),
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? colorScheme.primary
                                    : Colors.white,
                                width: isSelected ? 3 : 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ).animate().slideY(begin: -0.5, duration: 200.ms),
                  ),

                // Bottom bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _captionController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Add a caption...',
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _isUploading ? null : _postStory,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: _isUploading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Post',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading overlay
                if (_isUploading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Posting story...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
