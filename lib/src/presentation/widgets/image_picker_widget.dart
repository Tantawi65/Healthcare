import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final void Function(File image)? onImageSelected;
  final double? height;
  final double? width;

  const ImagePickerWidget({
    super.key,
    this.onImageSelected,
    this.height = 300,
    this.width = double.infinity,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      setState(() {
        _isLoading = false;
      });

      if (pickedFile == null) return;

      setState(() {
        _image = File(pickedFile.path);
      });

      if (widget.onImageSelected != null) {
        widget.onImageSelected!(_image!);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
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
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Select Image Source', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  _SourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _image == null
          ? _buildPlaceholder(theme)
          : _buildImagePreview(theme),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return InkWell(
      onTap: _showImageSourceDialog,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Tap to add an image',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose from gallery or take a photo',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(_image!, fit: BoxFit.cover),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showImageSourceDialog,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _image = null;
                });
                if (widget.onImageSelected != null) {
                  widget.onImageSelected!(File(''));
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
