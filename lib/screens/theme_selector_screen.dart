import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';

class ThemeSelectorScreen extends StatefulWidget {
  const ThemeSelectorScreen({super.key});

  @override
  State<ThemeSelectorScreen> createState() => _ThemeSelectorScreenState();
}

class _ThemeSelectorScreenState extends State<ThemeSelectorScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choose Theme',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: currentTheme.surface,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: currentTheme.primary,
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: currentTheme.surface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: currentTheme.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: currentTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: currentTheme.primary,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  currentTheme.icon,
                  size: 48,
                  color: currentTheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Current Theme',
                  style: TextStyle(
                    fontSize: 16,
                    color: currentTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentTheme.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: currentTheme.textPrimary,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentTheme.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: currentTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: AppTheme.allThemes.length,
              itemBuilder: (context, index) {
                final theme = AppTheme.allThemes[index];
                final isSelected = theme.id == currentTheme.id;
                return _buildThemeCard(theme, isSelected, themeProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(AppTheme theme, bool isSelected, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () async {
        await themeProvider.setTheme(theme);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Theme changed to ${theme.name}'),
              backgroundColor: theme.primary,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primary,
              theme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : theme.primary,
            width: isSelected ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.3 : 0.15),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 6 : 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _ThemePatternPainter(theme.tertiary),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.surface.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      theme.icon,
                      size: 40,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    theme.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.surface,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    theme.description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.surface.withOpacity(0.9),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: theme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemePatternPainter extends CustomPainter {
  final Color color;

  _ThemePatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Create a subtle pattern
    for (int i = 0; i < 20; i++) {
      final x = (i * 23 % size.width.toInt()).toDouble();
      final y = (i * 37 % size.height.toInt()).toDouble();
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
