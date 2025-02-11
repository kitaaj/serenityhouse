import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF5A7D9C),
    secondary: const Color(0xFF88C0A8),
    tertiary: const Color(0xFFF5F8FA),
    brightness: Brightness.light,
  ),
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: Color(0xFF2B3A4A),
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade800,
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.grey.shade800,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey.shade700,
      height: 1.6,
    ),
    labelLarge: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.5,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
      shape: const StadiumBorder(),
      backgroundColor: const Color(0xFF88C0A8),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      shadowColor: Colors.transparent,
      elevation: 0,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: const StadiumBorder(),
      side: const BorderSide(color: Color(0xFF88C0A8)),
      foregroundColor: const Color(0xFF5A7D9C),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(width: 0.0, color: Colors.transparent),
    ),
    filled: true,
    fillColor: Colors.grey.shade200,
    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
    prefixIconColor: Colors.grey.shade600,
    suffixIconColor: Colors.grey.shade600,
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.zero,
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    linearTrackColor: Colors.grey.shade200,
    color: const Color(0xFF88C0A8),
    circularTrackColor: Colors.transparent,
  ),
  appBarTheme: AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Light theme: dark icons
      statusBarBrightness: Brightness.light, // Light theme: light background
      systemNavigationBarColor: Colors.white, // Match scaffold
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
    backgroundColor: const Color(0xFF5A7D9C),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.3,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F8FA),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),

  dialogTheme: DialogTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4A6B8A),
    secondary: const Color(0xFF6A9D7B),
    tertiary: const Color(0xFF1A2833),
    brightness: Brightness.dark,
  ),
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade300,
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.grey.shade300,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey.shade400,
      height: 1.6,
    ),
    labelLarge: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      letterSpacing: 0.5,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
      shape: const StadiumBorder(),
      backgroundColor: const Color(0xFF6A9D7B),
      foregroundColor: Colors.black87,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      shadowColor: Colors.transparent,
      elevation: 0,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: const StadiumBorder(),
      side: const BorderSide(color: Color(0xFF6A9D7B)),
      foregroundColor: const Color(0xFF4A6B8A),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.grey.shade800,
    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
    prefixIconColor: Colors.grey.shade500,
    suffixIconColor: Colors.grey.shade500,
  ),
  cardTheme: CardTheme(
    color: const Color(0xFF1E1E1E),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.zero,
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    linearTrackColor: Colors.grey.shade700,
    color: const Color(0xFF6A9D7B),
    circularTrackColor: Colors.transparent,
  ),
  appBarTheme: AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Light theme: dark icons
      statusBarBrightness: Brightness.light, // Light theme: light background
      systemNavigationBarColor: Colors.white, // Match scaffold
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
    backgroundColor: const Color(0xFF1A2833),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.3,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  dialogTheme: DialogTheme(
    backgroundColor: const Color(0xFF1A2833),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF1A2833),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  ),
);
