import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';

class ThemePaletteWidget extends StatelessWidget {
  const ThemePaletteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor.withOpacity(0.9),
            border: Border(
              bottom: BorderSide(
                color: themeProvider.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
                child: Text(
                  'Quick Theme',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textSecondaryColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: AppTheme.allThemes.length,
                  itemBuilder: (context, index) {
                    final theme = AppTheme.allThemes[index];
                    final isSelected = theme.id == themeProvider.currentTheme.id;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _ThemeSwatch(
                        theme: theme,
                        isSelected: isSelected,
                        onTap: () {
                          themeProvider.setTheme(theme);
                          // Show feedback
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Theme changed to ${theme.name}'),
                              duration: const Duration(milliseconds: 800),
                              backgroundColor: theme.primary,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final AppTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeSwatch({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primary,
              theme.secondary,
            ],
          ),
          border: Border.all(
            color: isSelected ? theme.tertiary : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.4 : 0.2),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            theme.icon,
            size: isSelected ? 24 : 20,
            color: theme.surface,
          ),
        ),
      ),
    );
  }
}
