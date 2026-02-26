import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class PhotoEditorScreen extends StatefulWidget {
  final String imagePath;

  const PhotoEditorScreen({super.key, required this.imagePath});

  @override
  State<PhotoEditorScreen> createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends State<PhotoEditorScreen> {
  double _brightness = 0;
  double _contrast = 1;
  double _saturation = 1;
  String _selectedFilter = 'none';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _filters = [
    {'name': 'none', 'label': 'Original'},
    {'name': 'sepia', 'label': 'Sepia'},
    {'name': 'grayscale', 'label': 'B&W'},
    {'name': 'vintage', 'label': 'Vintage'},
    {'name': 'warm', 'label': 'Warm'},
    {'name': 'cool', 'label': 'Cool'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Photo',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF5F5DC),
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF8B4513),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFFF5F5DC)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isProcessing)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF5F5DC)),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check, color: Color(0xFFF5F5DC)),
              onPressed: _saveImage,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            color: const Color(0xFFF5F5DC),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildFilterList(),
                const SizedBox(height: 16),
                _buildAdjustments(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter['name'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = filter['name'] as String);
              },
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF8B4513)
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filter['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: const Color(0xFF8B4513),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdjustments() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildSlider(
            label: 'Brightness',
            value: _brightness,
            min: -1,
            max: 1,
            onChanged: (value) => setState(() => _brightness = value),
          ),
          _buildSlider(
            label: 'Contrast',
            value: _contrast,
            min: 0.5,
            max: 1.5,
            onChanged: (value) => setState(() => _contrast = value),
          ),
          _buildSlider(
            label: 'Saturation',
            value: _saturation,
            min: 0,
            max: 2,
            onChanged: (value) => setState(() => _saturation = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B4513),
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: const Color(0xFF8B4513),
          inactiveColor: const Color(0xFFC19A6B),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _saveImage() async {
    setState(() => _isProcessing = true);

    try {
      // Load original image
      final bytes = await File(widget.imagePath).readAsBytes();
      var image = img.decodeImage(bytes);

      if (image != null) {
        // Apply filter
        image = _applyFilter(image, _selectedFilter);

        // Apply adjustments
        image = img.adjustColor(
          image,
          brightness: _brightness,
          contrast: _contrast,
          saturation: _saturation,
        );

        // Save edited image
        final editedBytes = img.encodeJpg(image, quality: 95);
        await File(widget.imagePath).writeAsBytes(editedBytes);

        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error editing photo: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  img.Image _applyFilter(img.Image image, String filterName) {
    switch (filterName) {
      case 'sepia':
        return img.sepia(image);
      case 'grayscale':
        return img.grayscale(image);
      case 'vintage':
        var filtered = img.sepia(image);
        filtered = img.adjustColor(filtered, contrast: 1.2, saturation: 0.8);
        return filtered;
      case 'warm':
        return img.adjustColor(image, saturation: 1.2);
      case 'cool':
        return img.adjustColor(image, saturation: 0.8);
      default:
        return image;
    }
  }
}
