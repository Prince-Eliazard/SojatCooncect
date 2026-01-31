import 'package:flutter/material.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  // --- COULEURS STYLE FACEBOOK ---
  final Color fbBlue = const Color(0xFF1877F2); // Le bleu officiel de Facebook
  final Color fbGrey = const Color(0xFFF0F2F5); // Le gris de fond
  final Color fbWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fbGrey,
      appBar: AppBar(
        backgroundColor: fbWhite,
        elevation: 0.5,
        title: Text(
          "SodjaConnect",
          style: TextStyle(
            color: fbBlue, 
            fontWeight: FontWeight.bold, 
            fontSize: 28, 
            letterSpacing: -1.2
          ),
        ),
        actions: [
          _buildCircleButton(Icons.add_circle),
          _buildCircleButton(Icons.search),
          _buildCircleButton(Icons.messenger),
        ],
      ),
      body: ListView(
        children: [
          _buildCreatePostSection(),
          const SizedBox(height: 8),
          _buildStoriesSection(),
          const SizedBox(height: 8),
          // Liste de publications
          ...List.generate(5, (index) => _buildPostCard(index)),
        ],
      ),
    );
  }

  // --- SECTION QUOI DE NEUF ---
  Widget _buildCreatePostSection() {
    return Container(
      color: fbWhite,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: fbGrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("À quoi pensez-vous ?", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
          const Divider(height: 25, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAction(Icons.videocam, "En direct", Colors.red),
              _buildAction(Icons.photo_library, "Photo", Colors.green),
              _buildAction(Icons.video_call, "Salon", Colors.purple),
            ],
          )
        ],
      ),
    );
  }

  // --- SECTION STORIES ---
  Widget _buildStoriesSection() {
    return Container(
      height: 200,
      color: fbWhite,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 110,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: NetworkImage("https://picsum.photos/200/400?random=$index"),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET POST (CARTE) ---
  Widget _buildPostCard(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: fbWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text("Utilisateur Sodja", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Row(
              children: [
                const Text("2 h • "),
                Icon(Icons.public, size: 14, color: Colors.grey[600]),
              ],
            ),
            trailing: const Icon(Icons.more_horiz),
          ),
          const Padding(
           padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
            child: Text("Ceci est une publication test sur le nouveau fil d'actualité."),
          ),
          Image.network("https://picsum.photos/600/400?random=${index + 10}", fit: BoxFit.cover),
          _buildPostStats(),
          const Divider(height: 1, indent: 15, endIndent: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInteraction(Icons.thumb_up_off_alt, "J'aime"),
              _buildInteraction(Icons.chat_bubble_outline, "Commenter"),
              _buildInteraction(Icons.share_outlined, "Partager"),
            ],
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildCircleButton(IconData icon) => Container(
    margin: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: fbGrey, shape: BoxShape.circle),
    child: IconButton(icon: Icon(icon, color: Colors.black, size: 22), onPressed: () {}),
  );

  Widget _buildAction(IconData icon, String label, Color color) => Row(
    children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    ],
  );

  Widget _buildPostStats() => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: fbBlue, shape: BoxShape.circle),
              child: const Icon(Icons.thumb_up, color: Colors.white, size: 10),
            ),
            const SizedBox(width: 5),
            const Text("124"),
          ],
        ),
        const Text("12 commentaires • 4 partages"),
      ],
    ),
  );

  Widget _buildInteraction(IconData icon, String label) => TextButton.icon(
    onPressed: () {},
    icon: Icon(icon, color: Colors.grey[600]),
    label: Text(label, style: TextStyle(color: Colors.grey[600])),
  );
}