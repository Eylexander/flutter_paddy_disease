import 'package:flutter/material.dart';
import '../styles.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Light theme
  final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryRed,
      brightness: Brightness.light,
      primary: kPrimaryRed,
      secondary: kDarkRed,
      tertiary: kLightRed,
      surface: kBackgroundColor,
    ),
    scaffoldBackgroundColor: kBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: kPrimaryRed,
      foregroundColor: Colors.white,
      titleTextStyle: kAppBarTitleStyle,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: kPrimaryRed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withAlpha((0.6 * 255).toInt()),
      selectedLabelStyle: kNavBarLabelStyle,
      unselectedLabelStyle: kNavBarLabelStyle,
      elevation: 8.0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kDarkRed,
        foregroundColor: Colors.white,
        textStyle: kButtonTextStyle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: kPrimaryRed,
    ),
    fontFamily: kMainFont
  );

  // Dark theme
  final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryRed,
      brightness: Brightness.dark,
      primary: kPrimaryRed,
      secondary: kDarkRed,
      tertiary: kLightRed,
      surface: kDarkBackgroundColor,
    ),
    scaffoldBackgroundColor: kDarkBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: kDarkRed,
      foregroundColor: Colors.white,
      titleTextStyle: kAppBarTitleStyle,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: kDarkRed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withAlpha((0.6 * 255).toInt()),
      selectedLabelStyle: kNavBarLabelStyle,
      unselectedLabelStyle: kNavBarLabelStyle,
      elevation: 8.0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryRed,
        foregroundColor: Colors.white,
        textStyle: kButtonTextStyle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: kLightRed,
    ),
    fontFamily: kMainFont
  );
}
