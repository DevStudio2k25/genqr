import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/shadcn_colors.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = const Color(0xFF18181B); // Default Zinc

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      var brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeData get currentThemeString {
    return isDarkMode ? darkTheme : lightTheme;
  }

  // Dynamic color generation based on primary color
  Color get background =>
      isDarkMode ? const Color(0xFF09090B) : const Color(0xFFFFFFFF);

  Color get foreground =>
      isDarkMode ? const Color(0xFFFAFAFA) : const Color(0xFF09090B);

  Color get card =>
      isDarkMode ? const Color(0xFF09090B) : const Color(0xFFFFFFFF);

  Color get cardForeground =>
      isDarkMode ? const Color(0xFFFAFAFA) : const Color(0xFF09090B);

  Color get primary => _primaryColor;

  Color get primaryForeground {
    // Calculate contrast color for primary
    final luminance = _primaryColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Color get secondary =>
      isDarkMode ? _lighten(_primaryColor, 0.1) : _darken(_primaryColor, 0.9);

  Color get secondaryForeground =>
      isDarkMode ? const Color(0xFFFAFAFA) : const Color(0xFF18181B);

  Color get muted =>
      isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);

  Color get mutedForeground =>
      isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

  Color get border =>
      isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

  Color get input =>
      isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

  Color get ring => _primaryColor;

  Color get accent =>
      isDarkMode ? _lighten(_primaryColor, 0.2) : _lighten(_primaryColor, 0.8);

  Color get accentForeground => primaryForeground;

  // Helper methods to lighten/darken colors
  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  ThemeProvider() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[modeIndex];

    final colorVal = prefs.getInt('primary_color');
    if (colorVal != null) {
      _primaryColor = Color(colorVal);
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  void setCustomPrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primary_color', color.toARGB32());
  }

  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: primaryForeground,
        secondary: secondary,
        onSecondary: secondaryForeground,
        error: ShadcnColors.destructive,
        onError: ShadcnColors.destructiveForeground,
        surface: card,
        onSurface: cardForeground,
        outline: border,
      ),
      useMaterial3: true,
      fontFamily: 'Inter',
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: primaryForeground,
        secondary: secondary,
        onSecondary: secondaryForeground,
        error: ShadcnColors.destructiveDark,
        onError: ShadcnColors.destructiveForegroundDark,
        surface: card,
        onSurface: cardForeground,
        outline: border,
      ),
      useMaterial3: true,
      fontFamily: 'Inter',
    );
  }
}
