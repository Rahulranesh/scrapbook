import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.classic;
  static const String _themeKey = 'selected_theme';

  AppTheme get currentTheme => _currentTheme;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeId = prefs.getString(_themeKey) ?? 'classic';
    _currentTheme = AppTheme.getThemeById(themeId);
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.id);
  }

  // Helper methods to get current theme colors
  Color get primaryColor => _currentTheme.primary;
  Color get secondaryColor => _currentTheme.secondary;
  Color get tertiaryColor => _currentTheme.tertiary;
  Color get backgroundColor => _currentTheme.background;
  Color get surfaceColor => _currentTheme.surface;
  Color get textPrimaryColor => _currentTheme.textPrimary;
  Color get textSecondaryColor => _currentTheme.textSecondary;
}
