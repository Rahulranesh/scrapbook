import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../screens/sticker_library.dart';
import 'note_editor.dart';

class AddItemSheet extends StatelessWidget {
  const AddItemSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _TornPaperPainter(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Add to Scrapbook',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimaryColor,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuItem(
                context,
                icon: Icons.photo_camera,
                label: 'Add Photo',
                color: themeProvider.secondaryColor,
                onTap: () => _addPhoto(context),
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                icon: Icons.note,
                label: 'Add Note',
                color: const Color(0xFFFFF59D),
                onTap: () => _addNote(context),
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                icon: Icons.star,
                label: 'Add Sticker',
                color: const Color(0xFFFFD700),
                onTap: () => _addSticker(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeProvider.primaryColor.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && context.mounted) {
      Navigator.pop(context, {
        'type': 'photo',
        'content': pickedFile.path,
      });
    }
  }

  Future<void> _addNote(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const NoteEditor(),
    );

    if (result != null && context.mounted) {
      Navigator.pop(context, {
        'type': 'note',
        'content': result['text'],
        'color': result['color'],
      });
    }
  }

  Future<void> _addSticker(BuildContext context) async {
    final stickerType = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: const StickerLibrary(),
      ),
    );

    if (stickerType != null && context.mounted) {
      Navigator.pop(context, {
        'type': 'sticker',
        'content': stickerType,
      });
    }
  }
}

class _TornPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0C0A0).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Create torn edge effect at top
    final path = Path();
    path.moveTo(0, 20);
    
    for (double i = 0; i < size.width; i += 10) {
      final y = 20.0 + (i % 20 == 0 ? 3.0 : -2.0);
      path.lineTo(i, y);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
