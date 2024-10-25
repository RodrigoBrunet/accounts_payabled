import 'package:flutter/material.dart';

final ThemeData myTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF3E0065), // Roxo profundo
    secondary: Color(0xFF5A007F), // Roxo médio
    background: Color(0xFFF3E5F5), // Rosa claro
    surface: Color(0xFF7E009D), // Roxo claro
    error: Color(0xFFD32F2F), // Vermelho intenso
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.black,
    onSurface: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(iconTheme: IconThemeData(color: Colors.white)),
  textTheme: TextTheme(
    displayLarge: const TextStyle(color: Color(0xFF3E0065)), // Roxo profundo
    bodyLarge: const TextStyle(color: Colors.black), // Preto
    bodyMedium: TextStyle(color: Colors.grey[800]), // Cinza-escuro
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: const Color(0xFF5A007F), // Roxo médio
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF3E0065)), // Roxo profundo
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF5A007F)), // Roxo médio
    ),
  ),
);
