import 'package:flutter/material.dart';
import 'login_page.dart';

class Acceuil extends StatefulWidget {
  const Acceuil({super.key});

  @override
  State<Acceuil> createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final Color whiteBg = const Color(0xFFF8F8FF); 
  final Color indigoDark = const Color(0xFF1A237E); 

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    
    // CORRECTION ICI : Curves.elasticOut au lieu de backOut
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBg,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(Icons.shopping_bag_rounded, size: 100, color: indigoDark),
            ),
            const SizedBox(height: 20),
            Text(
                "SojatConnect",
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w900,
                    color: indigoDark,
                    letterSpacing: 2
                )
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: indigoDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                elevation: 5,
              ),
              onPressed: () => Navigator.push(context, _createRoute(const LoginPage())),
              child: const Text("COMMENCER", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}