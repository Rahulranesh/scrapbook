import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class VintageLoading extends StatefulWidget {
  final String message;

  const VintageLoading({
    super.key,
    this.message = 'Loading...',
  });

  @override
  State<VintageLoading> createState() => _VintageLoadingState();
}

class _VintageLoadingState extends State<VintageLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spinning film reel
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * 3.14159,
                child: CustomPaint(
                  painter: _FilmReelPainter(
                    primaryColor: themeProvider.primaryColor,
                    surfaceColor: themeProvider.surfaceColor,
                  ),
                  size: const Size(80, 80),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            widget.message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimaryColor,
              fontFamily: 'serif',
            ),
          ),
        ],
      ),
    );
  }
}

class _FilmReelPainter extends CustomPainter {
  final Color primaryColor;
  final Color surfaceColor;

  _FilmReelPainter({
    required this.primaryColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle
    canvas.drawCircle(center, radius, paint);

    // Inner circle (hole)
    paint.color = surfaceColor;
    canvas.drawCircle(center, radius * 0.3, paint);

    // Film holes around the edge
    paint.color = surfaceColor;
    for (int i = 0; i < 8; i++) {
      final angle = (i * 3.14159 * 2) / 8;
      final x = center.dx + (radius * 0.65) * Math.cos(angle);
      final y = center.dy + (radius * 0.65) * Math.sin(angle);
      canvas.drawCircle(Offset(x, y), radius * 0.15, paint);
    }

    // Spokes
    paint.color = primaryColor.withOpacity(0.7);
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    for (int i = 0; i < 4; i++) {
      final angle = (i * 3.14159 * 2) / 4;
      final x1 = center.dx + (radius * 0.3) * Math.cos(angle);
      final y1 = center.dy + (radius * 0.3) * Math.sin(angle);
      final x2 = center.dx + (radius * 0.5) * Math.cos(angle);
      final y2 = center.dy + (radius * 0.5) * Math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper class for math functions
class Math {
  static double cos(double radians) => radians.cos();
  static double sin(double radians) => radians.sin();
}

extension on double {
  double cos() {
    // Simple cosine approximation
    final x = this % (2 * 3.14159);
    return 1 - (x * x) / 2 + (x * x * x * x) / 24;
  }

  double sin() {
    // Simple sine approximation
    final x = this % (2 * 3.14159);
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }
}
