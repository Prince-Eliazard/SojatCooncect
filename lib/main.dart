import 'package:flutter/material.dart';
import 'acceuil.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SojatConnect',
      theme: ThemeData(
        useMaterial3: true,
        // On définit un ColorScheme basé sur le blanc
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF8F8FF), // Votre blanc "Ghost White"
          primary: const Color(0xFFF8F8FF),   // Couleur principale
          surface: Colors.white,              // Couleur des cartes et fonds
        ),
        // Force le fond de l'application en blanc pur ou Ghost White
        scaffoldBackgroundColor: const Color(0xFFF8F8FF),

        // Optionnel : s'assurer que l'AppBar soit aussi blanche
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F8FF),
          elevation: 0,
        ),
      ),
      home: const Acceuil(),
    );
  }
}