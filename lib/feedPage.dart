import 'package:flutter/material.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  int _selectedIndex = 0;
  final Color indigoDark = const Color(0xFF1A237E);
  final Color accentBlue = const Color(0xFF2196F3);
  final Color whiteBg = const Color(0xFFF8F8FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBg,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text(
          "SojatConnect",
          style: TextStyle(
            color: accentBlue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        // --- MODIFICATION ICI : On supprime le contenu de actions ---
        actions: const [], 
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Profil et Demande d'Achat
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Demande d'Achat",
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text(
                "Fil d'actualité",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: indigoDark,
                ),
              ),
            ),
            _buildPostCard(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: accentBlue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Acceuil"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Notifs"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Paramètres"),
        ],
      ),
    );
  }

  Widget _buildPostCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: CircleAvatar(backgroundColor: Colors.indigo, radius: 18),
            title: Text("Omar Le Riche", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("21 min"),
            trailing: Icon(Icons.more_horiz),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Contenu du fil d'actualité..."),
          ),
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey.shade100,
            child: const Icon(Icons.image, size: 50, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}