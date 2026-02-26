import 'package:flutter/material.dart';

class PaperTextureOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;

  const PaperTextureOverlay({
    super.key,
    required this.child,
    this.opacity = 0.03,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _PaperTexturePainter(opacity: opacity),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaperTexturePainter extends CustomPainter {
  final double opacity;

  _PaperTexturePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Add subtle paper grain texture
    for (int i = 0; i < 500; i++) {
      final x = (i * 37 % size.width.toInt()).toDouble();
      final y = (i * 73 % size.height.toInt()).toDouble();
      
      paint.color = Colors.black.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 0.5, paint);
      
      paint.color = Colors.white.withOpacity(opacity * 0.5);
      canvas.drawCircle(Offset(x + 2, y + 2), 0.3, paint);
    }

    // Add some subtle lines for paper texture
    paint.strokeWidth = 0.2;
    for (int i = 0; i < 100; i++) {
      final x = (i * 67 % size.width.toInt()).toDouble();
      final y = (i * 89 % size.height.toInt()).toDouble();
      
      paint.color = Colors.black.withOpacity(opacity * 0.5);
      canvas.drawLine(
        Offset(x, y),
        Offset(x + 8, y + 1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
