import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Font constants
const String kMainFont = 'Sora';
const String kButtonFont = 'Sora';
const String kDisplayFont = 'Sora';

// Color constants - Red theme
const Color kPrimaryRed = Color.fromARGB(255, 229, 57, 53);
const Color kDarkRed = Color(0xFFC62828);
const Color kLightRed = Color(0xFFEF5350);
const Color kVeryLightRed = Color.fromARGB(255, 255, 146, 126);
const Color kAccentColor = Color(0xFFFFCDD2);
const Color kBackgroundColor = Color(0xFFFAFAFA);
const Color kDarkBackgroundColor = Color(0xFF212121);

// Theme colors
const Color kBgColor = kLightRed;

// Text styles
TextStyle kTitleTextStyle = GoogleFonts.sora(
  fontSize: 32.0,
  fontWeight: FontWeight.bold,
  color: Colors.white,
  decoration: TextDecoration.none,
);

TextStyle kAnalyzingTextStyle = GoogleFonts.sora(
  fontSize: 22.0,
  fontWeight: FontWeight.w500,
  color: Colors.white,
  decoration: TextDecoration.none,
);

TextStyle kResultTextStyle = GoogleFonts.sora(
  fontSize: 28.0,
  fontWeight: FontWeight.bold,
  color: Colors.white,
  decoration: TextDecoration.none,
);

TextStyle kResultRatingTextStyle = GoogleFonts.sora(
  fontSize: 16.0,
  fontWeight: FontWeight.normal,
  color: Colors.white,
  decoration: TextDecoration.none,
);

TextStyle kButtonTextStyle = GoogleFonts.sora(
  fontSize: 18.0,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

TextStyle kAppBarTitleStyle = GoogleFonts.sora(
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

TextStyle kNavBarLabelStyle = GoogleFonts.sora(
  fontSize: 12.0,
  fontWeight: FontWeight.w500,
);

// Progress bar colors
const List<Color> kProgressBarColors = [
  Color(0xFFE53935), // Primary red
  Color(0xFFEF5350), // Light red
  Color(0xFFFFCDD2), // Accent color
];
