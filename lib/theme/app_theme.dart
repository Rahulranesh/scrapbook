import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  final String id;
  final String name;
  final String description;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final String fontFamily;
  final IconData icon;

  const AppTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.fontFamily,
    required this.icon,
  });

  ThemeData toThemeData() {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        background: background,
      ),
      useMaterial3: true,
      textTheme: _getTextTheme(),
      fontFamily: _getFontFamily(),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: surface,
        elevation: 4,
        centerTitle: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: tertiary,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: surface,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  TextTheme _getTextTheme() {
    switch (fontFamily) {
      case 'Special Elite':
        return GoogleFonts.specialEliteTextTheme();
      case 'Caveat':
        return GoogleFonts.caveatTextTheme();
      case 'Pacifico':
        return GoogleFonts.pacificoTextTheme();
      case 'Dancing Script':
        return GoogleFonts.dancingScriptTextTheme();
      case 'Permanent Marker':
        return GoogleFonts.permanentMarkerTextTheme();
      case 'Indie Flower':
        return GoogleFonts.indieFlowerTextTheme();
      default:
        return GoogleFonts.specialEliteTextTheme();
    }
  }

  String _getFontFamily() {
    switch (fontFamily) {
      case 'Special Elite':
        return GoogleFonts.specialElite().fontFamily!;
      case 'Caveat':
        return GoogleFonts.caveat().fontFamily!;
      case 'Pacifico':
        return GoogleFonts.pacifico().fontFamily!;
      case 'Dancing Script':
        return GoogleFonts.dancingScript().fontFamily!;
      case 'Permanent Marker':
        return GoogleFonts.permanentMarker().fontFamily!;
      case 'Indie Flower':
        return GoogleFonts.indieFlower().fontFamily!;
      default:
        return GoogleFonts.specialElite().fontFamily!;
    }
  }

  // Predefined themes
  static const AppTheme classic = AppTheme(
    id: 'classic',
    name: 'Classic Brown',
    description: 'Traditional vintage scrapbook',
    primary: Color(0xFF8B4513),
    secondary: Color(0xFFC19A6B),
    tertiary: Color(0xFF2D5016),
    background: Color(0xFFF5F5DC),
    surface: Color(0xFFF5F5DC),
    textPrimary: Color(0xFF8B4513),
    textSecondary: Color(0xFF654321),
    fontFamily: 'Special Elite',
    icon: Icons.auto_stories,
  );

  static const AppTheme sepia = AppTheme(
    id: 'sepia',
    name: 'Sepia Dreams',
    description: 'Warm nostalgic tones',
    primary: Color(0xFF704214),
    secondary: Color(0xFFD4A574),
    tertiary: Color(0xFF8B6F47),
    background: Color(0xFFFFF8E7),
    surface: Color(0xFFFFF8E7),
    textPrimary: Color(0xFF704214),
    textSecondary: Color(0xFF8B6F47),
    fontFamily: 'Caveat',
    icon: Icons.wb_sunny,
  );

  static const AppTheme forest = AppTheme(
    id: 'forest',
    name: 'Forest Green',
    description: 'Nature-inspired palette',
    primary: Color(0xFF2D5016),
    secondary: Color(0xFF6B8E23),
    tertiary: Color(0xFF8FBC8F),
    background: Color(0xFFF0F8E8),
    surface: Color(0xFFF0F8E8),
    textPrimary: Color(0xFF2D5016),
    textSecondary: Color(0xFF556B2F),
    fontFamily: 'Indie Flower',
    icon: Icons.forest,
  );

  static const AppTheme ocean = AppTheme(
    id: 'ocean',
    name: 'Ocean Blue',
    description: 'Calm coastal vibes',
    primary: Color(0xFF1E4D7B),
    secondary: Color(0xFF5B9BD5),
    tertiary: Color(0xFF87CEEB),
    background: Color(0xFFE8F4F8),
    surface: Color(0xFFE8F4F8),
    textPrimary: Color(0xFF1E4D7B),
    textSecondary: Color(0xFF2E5C8A),
    fontFamily: 'Dancing Script',
    icon: Icons.waves,
  );

  static const AppTheme sunset = AppTheme(
    id: 'sunset',
    name: 'Sunset Orange',
    description: 'Warm evening glow',
    primary: Color(0xFFD2691E),
    secondary: Color(0xFFFF8C42),
    tertiary: Color(0xFFFFB347),
    background: Color(0xFFFFF5E6),
    surface: Color(0xFFFFF5E6),
    textPrimary: Color(0xFFD2691E),
    textSecondary: Color(0xFF8B4513),
    fontFamily: 'Pacifico',
    icon: Icons.wb_twilight,
  );

  static const AppTheme lavender = AppTheme(
    id: 'lavender',
    name: 'Lavender Dreams',
    description: 'Soft purple elegance',
    primary: Color(0xFF6B4C8A),
    secondary: Color(0xFF9B7EBD),
    tertiary: Color(0xFFD8BFD8),
    background: Color(0xFFF8F4FF),
    surface: Color(0xFFF8F4FF),
    textPrimary: Color(0xFF6B4C8A),
    textSecondary: Color(0xFF8B6FA8),
    fontFamily: 'Dancing Script',
    icon: Icons.spa,
  );

  static const AppTheme rose = AppTheme(
    id: 'rose',
    name: 'Rose Garden',
    description: 'Romantic pink tones',
    primary: Color(0xFF8B4C5C),
    secondary: Color(0xFFD8A7B1),
    tertiary: Color(0xFFFFB6C1),
    background: Color(0xFFFFF0F5),
    surface: Color(0xFFFFF0F5),
    textPrimary: Color(0xFF8B4C5C),
    textSecondary: Color(0xFFA0606E),
    fontFamily: 'Caveat',
    icon: Icons.local_florist,
  );

  static const AppTheme midnight = AppTheme(
    id: 'midnight',
    name: 'Midnight Blue',
    description: 'Deep evening elegance',
    primary: Color(0xFF191970),
    secondary: Color(0xFF4169E1),
    tertiary: Color(0xFF6495ED),
    background: Color(0xFFE6E8F0),
    surface: Color(0xFFE6E8F0),
    textPrimary: Color(0xFF191970),
    textSecondary: Color(0xFF2F4F7F),
    fontFamily: 'Special Elite',
    icon: Icons.nightlight,
  );

  static const AppTheme autumn = AppTheme(
    id: 'autumn',
    name: 'Autumn Leaves',
    description: 'Fall harvest colors',
    primary: Color(0xFF8B4513),
    secondary: Color(0xFFCD853F),
    tertiary: Color(0xFFDEB887),
    background: Color(0xFFFFF8DC),
    surface: Color(0xFFFFF8DC),
    textPrimary: Color(0xFF8B4513),
    textSecondary: Color(0xFF654321),
    fontFamily: 'Permanent Marker',
    icon: Icons.eco,
  );

  static const AppTheme mint = AppTheme(
    id: 'mint',
    name: 'Mint Fresh',
    description: 'Cool refreshing green',
    primary: Color(0xFF2E8B57),
    secondary: Color(0xFF66CDAA),
    tertiary: Color(0xFF98FB98),
    background: Color(0xFFF0FFF0),
    surface: Color(0xFFF0FFF0),
    textPrimary: Color(0xFF2E8B57),
    textSecondary: Color(0xFF3CB371),
    fontFamily: 'Indie Flower',
    icon: Icons.local_cafe,
  );

  static const AppTheme coral = AppTheme(
    id: 'coral',
    name: 'Coral Reef',
    description: 'Vibrant coral tones',
    primary: Color(0xFFFF6B6B),
    secondary: Color(0xFFFF8E8E),
    tertiary: Color(0xFFFFB4B4),
    background: Color(0xFFFFF5F5),
    surface: Color(0xFFFFF5F5),
    textPrimary: Color(0xFFFF6B6B),
    textSecondary: Color(0xFFE85555),
    fontFamily: 'Pacifico',
    icon: Icons.water,
  );

  static const AppTheme vintage = AppTheme(
    id: 'vintage',
    name: 'Vintage Paper',
    description: 'Aged paper aesthetic',
    primary: Color(0xFF8B7355),
    secondary: Color(0xFFD2B48C),
    tertiary: Color(0xFFDEB887),
    background: Color(0xFFFAF0E6),
    surface: Color(0xFFFAF0E6),
    textPrimary: Color(0xFF8B7355),
    textSecondary: Color(0xFF6B5D4F),
    fontFamily: 'Special Elite',
    icon: Icons.history_edu,
  );

  static List<AppTheme> get allThemes => [
        classic,
        sepia,
        forest,
        ocean,
        sunset,
        lavender,
        rose,
        midnight,
        autumn,
        mint,
        coral,
        vintage,
      ];

  static AppTheme getThemeById(String id) {
    return allThemes.firstWhere(
      (theme) => theme.id == id,
      orElse: () => classic,
    );
  }
}
