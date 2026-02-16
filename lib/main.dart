import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'acceuil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de Firebase
  // PS: Si cette commande plante, c'est que le fichier firebase_options.dart n'est pas encore créé
  // Il faudra exécuter `flutterfire configure` dans le terminal.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch(e) {
    print("WARNING: Firebase non configuré. Veuillez exécuter 'flutterfire configure'. Erreur: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SojatConnect',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF8F8FF),
          primary: const Color(0xFFF8F8FF),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F8FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F8FF),
          elevation: 0,
        ),
      ),
      home: const Acceuil(),
    );
  }
}