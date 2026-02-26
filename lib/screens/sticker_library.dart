import 'package:flutter/material.dart';

class StickerLibrary extends StatelessWidget {
  const StickerLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5DC), // Cream
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          // Handle bar
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sticker Library',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B4513),
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: const Color(0xFF8B4513),
                    unselectedLabelColor: const Color(0xFF8B4513).withOpacity(0.5),
                    indicatorColor: const Color(0xFF8B4513),
                    tabs: const [
                      Tab(text: 'School'),
                      Tab(text: 'Emotions'),
                      Tab(text: '80s/90s'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildStickerGrid(_schoolStickers),
                        _buildStickerGrid(_emotionStickers),
                        _buildStickerGrid(_retroStickers),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerGrid(List<Map<String, dynamic>> stickers) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        final sticker = stickers[index];
        return _buildStickerItem(context, sticker);
      },
    );
  }

  Widget _buildStickerItem(BuildContext context, Map<String, dynamic> sticker) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, sticker['type']),
      child: Container(
        decoration: BoxDecoration(
          color: sticker['color'] as Color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: sticker['widget'] != null
              ? sticker['widget'] as Widget
              : Icon(
                  sticker['icon'] as IconData,
                  size: 40,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  static final List<Map<String, dynamic>> _schoolStickers = [
    {
      'type': 'star',
      'icon': Icons.star,
      'color': Color(0xFFFFD700), // Gold
    },
    {
      'type': 'trophy',
      'icon': Icons.emoji_events,
      'color': Color(0xFFFFD700), // Gold
    },
    {
      'type': 'book',
      'icon': Icons.menu_book,
      'color': Color(0xFF8B4513), // Brown
    },
    {
      'type': 'pencil',
      'icon': Icons.edit,
      'color': Color(0xFFFFEB3B), // Yellow
    },
    {
      'type': 'apple',
      'icon': Icons.apple,
      'color': Color(0xFFE53935), // Red
    },
    {
      'type': 'graduation',
      'icon': Icons.school,
      'color': Color(0xFF1976D2), // Blue
    },
  ];

  static final List<Map<String, dynamic>> _emotionStickers = [
    {
      'type': 'smile',
      'icon': Icons.sentiment_very_satisfied,
      'color': Color(0xFFFFEB3B), // Yellow
    },
    {
      'type': 'heart',
      'icon': Icons.favorite,
      'color': Color(0xFFFF69B4), // Hot pink
    },
    {
      'type': 'thumbs_up',
      'icon': Icons.thumb_up,
      'color': Color(0xFF4CAF50), // Green
    },
    {
      'type': 'cool',
      'widget': _CoolSticker(),
      'color': Color(0xFF00BCD4), // Cyan
    },
    {
      'type': 'rad',
      'widget': _RadSticker(),
      'color': Color(0xFFFF5722), // Orange
    },
    {
      'type': 'love',
      'icon': Icons.favorite_border,
      'color': Color(0xFFE91E63), // Pink
    },
  ];

  static final List<Map<String, dynamic>> _retroStickers = [
    {
      'type': 'music',
      'icon': Icons.music_note,
      'color': Color(0xFF9C27B0), // Purple
    },
    {
      'type': 'cassette',
      'widget': _CassetteSticker(),
      'color': Color(0xFF424242), // Dark gray
    },
    {
      'type': 'boombox',
      'widget': _BoomboxSticker(),
      'color': Color(0xFF212121), // Black
    },
    {
      'type': 'rainbow',
      'widget': _RainbowSticker(),
      'color': Color(0xFFFFFFFF), // White background
    },
    {
      'type': 'sun',
      'icon': Icons.wb_sunny,
      'color': Color(0xFFFF9800), // Orange
    },
    {
      'type': 'flower',
      'icon': Icons.local_florist,
      'color': Color(0xFFE91E63), // Pink
    },
    {
      'type': 'peace',
      'widget': _PeaceSticker(),
      'color': Color(0xFF4CAF50), // Green
    },
    {
      'type': 'lightning',
      'icon': Icons.flash_on,
      'color': Color(0xFFFFEB3B), // Yellow
    },
    {
      'type': 'rocket',
      'icon': Icons.rocket_launch,
      'color': Color(0xFF2196F3), // Blue
    },
  ];
}

class _CoolSticker extends StatelessWidget {
  const _CoolSticker();

  @override
  Widget build(BuildContext context) {
    return const FittedBox(
      child: Text(
        'COOL',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _RadSticker extends StatelessWidget {
  const _RadSticker();

  @override
  Widget build(BuildContext context) {
    return const FittedBox(
      child: Text(
        'RAD!',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _CassetteSticker extends StatelessWidget {
  const _CassetteSticker();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CassettePainter(),
      size: const Size(50, 50),
    );
  }
}

class _CassettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Cassette body
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.25, size.width * 0.6, size.height * 0.5),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, paint);

    // Reels
    paint.color = const Color(0xFF424242);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.45), size.width * 0.08, paint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.45), size.width * 0.08, paint);

    // Label area
    paint.color = Colors.white70;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.1),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BoomboxSticker extends StatelessWidget {
  const _BoomboxSticker();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BoomboxPainter(),
      size: const Size(50, 50),
    );
  }
}

class _BoomboxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Main body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.3, size.width * 0.7, size.height * 0.5),
        const Radius.circular(4),
      ),
      paint,
    );

    // Speakers
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.55), size.width * 0.1, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.55), size.width * 0.1, paint);

    // Antenna
    paint.strokeWidth = 1.5;
    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width * 0.9, size.height * 0.1),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RainbowSticker extends StatelessWidget {
  const _RainbowSticker();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RainbowPainter(),
      size: const Size(50, 50),
    );
  }
}

class _RainbowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height * 0.7);

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      final radius = size.width * 0.4 - (i * 3);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        3.14,
        3.14,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PeaceSticker extends StatelessWidget {
  const _PeaceSticker();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PeacePainter(),
      size: const Size(50, 50),
    );
  }
}

class _PeacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Outer circle
    canvas.drawCircle(center, radius, paint);

    // Peace symbol lines
    canvas.drawLine(center, Offset(center.dx, center.dy + radius), paint);
    canvas.drawLine(
      center,
      Offset(center.dx - radius * 0.7, center.dy + radius * 0.7),
      paint,
    );
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.7, center.dy + radius * 0.7),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
