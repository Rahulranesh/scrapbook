import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoteEditor extends StatefulWidget {
  final String? initialText;
  final Color? initialColor;

  const NoteEditor({
    super.key,
    this.initialText,
    this.initialColor,
  });

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController _textController;
  late Color _selectedColor;
  static const int _maxCharacters = 200;

  final List<Map<String, dynamic>> _noteColors = [
    {'name': 'Yellow', 'color': Color(0xFFFFF59D)},
    {'name': 'Pink', 'color': Color(0xFFFFC1E3)},
    {'name': 'Blue', 'color': Color(0xFFB3E5FC)},
    {'name': 'Green', 'color': Color(0xFFC8E6C9)},
    {'name': 'Orange', 'color': Color(0xFFFFCC80)},
    {'name': 'Purple', 'color': Color(0xFFE1BEE7)},
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? '');
    _selectedColor = widget.initialColor ?? const Color(0xFFFFF59D);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  int get _remainingCharacters => _maxCharacters - _textController.text.length;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: _selectedColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Paper texture
            CustomPaint(
              painter: _PaperTexturePainter(),
              child: Container(),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Write a Note',
                    style: GoogleFonts.caveat(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Text field
                  TextField(
                    controller: _textController,
                    maxLines: 8,
                    maxLength: _maxCharacters,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Type your note here...',
                      hintStyle: GoogleFonts.caveat(
                        fontSize: 20,
                        color: Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[600]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: _selectedColor.withOpacity(0.5),
                      counterText: '',
                    ),
                    style: GoogleFonts.caveat(
                      fontSize: 20,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  
                  // Character counter
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$_remainingCharacters characters left',
                          style: GoogleFonts.caveat(
                            fontSize: 16,
                            color: _remainingCharacters < 20
                                ? Colors.red[700]
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Color picker
                  Text(
                    'Note Color',
                    style: GoogleFonts.caveat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _noteColors.map((colorData) {
                      final color = colorData['color'] as Color;
                      final isSelected = color == _selectedColor;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.grey[800]!
                                  : Colors.grey[400]!,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Colors.grey[800],
                                  size: 28,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildPaperButton(
                        label: 'Cancel',
                        color: Colors.grey[400]!,
                        textColor: Colors.grey[800]!,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      _buildPaperButton(
                        label: 'Save Note',
                        color: const Color(0xFFFFEE58),
                        textColor: Colors.grey[800]!,
                        onPressed: () {
                          if (_textController.text.isNotEmpty) {
                            Navigator.pop(context, {
                              'text': _textController.text,
                              'color': _selectedColor,
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Curl effect at bottom right
            Positioned(
              bottom: 0,
              right: 0,
              child: CustomPaint(
                painter: _CurlPainter(color: _selectedColor),
                size: const Size(40, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[600]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.caveat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Add subtle paper texture
    for (int i = 0; i < 100; i++) {
      final x = (i * 31 % size.width.toInt()).toDouble();
      final y = (i * 47 % size.height.toInt()).toDouble();
      
      paint.color = Colors.white.withOpacity(0.1);
      canvas.drawCircle(Offset(x, y), 1, paint);
    }

    // Add some horizontal lines for ruled paper effect
    paint.color = Colors.grey.withOpacity(0.1);
    paint.strokeWidth = 0.5;
    for (double i = 80; i < size.height - 40; i += 30) {
      canvas.drawLine(
        Offset(24, i),
        Offset(size.width - 24, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CurlPainter extends CustomPainter {
  final Color color;

  _CurlPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _darkenColor(color, 0.1)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.6,
        0,
        size.height,
      )
      ..close();

    canvas.drawPath(path, paint);

    // Shadow for curl
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, shadowPaint);
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
