import 'package:flutter/material.dart';

const Color primaryColorLight = Color(0xFFDEA666);
const Color primaryDarkColor = Color(0xFF8E7051);
const Color primaryLightColor = Color(0xFFE6BA88);

const Color secondaryColorLight = Color(0xFF5B4632);
const Color successColorLight = Color(0xFF3FA34D);
const Color warningColorLight = Color(0xFFF59E0B);
const Color errorColorLight = Color(0xFFDC2626);
const Color infoColorLight = Color(0xFF4F46E5);

const Color backgroundLight = Color(0xFFFFFDF9);
const Color surfaceLight = Color(0xFFFFFFFF);
const Color outlineLight = Color(0xFFE5E1DA);

ThemeData lightTheme = ThemeData(
  useMaterial3: false,
  brightness: Brightness.light,
  primaryColor: primaryColorLight,
  scaffoldBackgroundColor: backgroundLight,
  cardColor: surfaceLight,
  disabledColor: const Color(0xFFA0A4A8),
  hintColor: const Color(0xFF9CA3AF),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: primaryDarkColor),
  ),

  colorScheme: const ColorScheme.light(
    primary: primaryColorLight,
    primaryContainer: primaryLightColor,
    secondary: secondaryColorLight,
    tertiary: infoColorLight,
    error: errorColorLight,
    background: backgroundLight,
    surface: surfaceLight,
    outline: outlineLight,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: surfaceLight,
    foregroundColor: primaryDarkColor,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: primaryDarkColor,
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColorLight,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: surfaceLight,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: outlineLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryColorLight),
    ),
  ),

  dividerColor: outlineLight,
);
