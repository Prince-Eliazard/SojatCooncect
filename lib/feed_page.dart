import 'package:flutter/material.dart';
import 'dart:convert'; // Pour base64
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'create_post_section.dart';
import 'login_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = "";
  bool _isSearching = false;
  
  // --- COULEURS STYLE FACEBOOK ---
  final Color fbBlue = const Color(0xFF1877F2); 
  final Color fbGrey = const Color(0xFFF0F2F5); 
  final Color fbWhite = Colors.white;

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fbGrey,
      appBar: AppBar(
        backgroundColor: fbWhite,
        elevation: 0.5,
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Rechercher une publication...",
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            )
          : Text(
              "SodjaConnect",
              style: TextStyle(
                color: fbBlue, 
                fontWeight: FontWeight.bold, 
                fontSize: 28, 
                letterSpacing: -1.2
              ),
            ),
        actions: [
          _buildCircleButton(_isSearching ? Icons.close : Icons.search, () {
            setState(() {
              if (_isSearching) {
                _isSearching = false;
                _searchQuery = "";
                _searchController.clear();
              } else {
                _isSearching = true;
              }
            });
          }),
          _buildCircleButton(Icons.add, _scrollToTop),
          _buildCircleButton(Icons.logout, () async {
            await _authService.signOut();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          }),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _authService.getPostsStream(searchQuery: _searchQuery),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final docs = snapshot.data!.docs;

          return ListView(
            controller: _scrollController,
            children: [
              const CreatePostSection(),
              const SizedBox(height: 8),
              if (docs.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(child: Text(_searchQuery.isEmpty 
                      ? "Aucune publication pour le moment. Soyez le premier !"
                      : "Aucun résultat pour '$_searchQuery'")),
                ),
              // Liste de publications réelles
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildPostCard(data, doc.id);
              }).toList(),
            ],
          );
        }
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> data, String docId) {
    String authorName = data['authorName'] ?? 'Anonyme';
    String? authorPhotoBase64 = data['authorPhoto'];
    String content = data['content'] ?? '';
    String? imageBase64 = data['imageBase64']; 
    Timestamp? timestamp = data['timestamp'];
    List<dynamic> likes = data['likes'] is List ? data['likes'] : [];
    int commentCount = data['commentCount'] ?? 0;
    int shares = data['shares'] ?? 0;

    bool isLiked = likes.contains(_authService.currentUser?.uid);
    
    String timeAgo = timestamp != null 
        ? "${DateTime.now().difference(timestamp.toDate()).inHours} h" 
        : "À l'instant";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: fbWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: (authorPhotoBase64 != null && authorPhotoBase64.isNotEmpty) 
                  ? MemoryImage(base64Decode(authorPhotoBase64)) 
                  : null,
              child: (authorPhotoBase64 == null || authorPhotoBase64.isEmpty) ? const Icon(Icons.person) : null,
            ),
            title: Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Row(
              children: [
                Text("$timeAgo • "),
                Icon(Icons.public, size: 14, color: Colors.grey[600]),
              ],
            ),
            trailing: const Icon(Icons.more_horiz),
          ),
          if (content.isNotEmpty)
            Padding(
             padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
              child: Text(content, style: const TextStyle(fontSize: 15)),
            ),
            
          if (imageBase64 != null && imageBase64.isNotEmpty)
            Image.memory(
              base64Decode(imageBase64), 
              fit: BoxFit.cover, 
              width: double.infinity, 
              height: 250, 
              errorBuilder: (c,e,s) => Container(
                height: 200, 
                color: Colors.grey[200], 
                child: const Center(child: Icon(Icons.broken_image))
              )
            ),

          _buildPostStats(likes.length, commentCount, shares),
          const Divider(height: 1, indent: 15, endIndent: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInteraction(
                isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt, 
                "J'aime", 
                isLiked ? fbBlue : Colors.grey[600],
                () async {
                  try {
                    await _authService.toggleLike(docId, data['likes']);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Oups: $e")));
                  }
                }
              ),
              _buildInteraction(Icons.chat_bubble_outline, "Commenter", Colors.grey[600], () => _showComments(docId)),
              _buildInteraction(Icons.share_outlined, "Partager", Colors.grey[600], () async {
                try {
                  await _handleShare(docId);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur partage: $e")));
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  // --- ACTIONS ---
  void _showComments(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final TextEditingController _commentCtrl = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text("Commentaires", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Divider(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _authService.getCommentsStream(postId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final comments = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final c = comments[index].data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(c['userName'] ?? 'Anonyme', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(c['text'] ?? ''),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          decoration: InputDecoration(
                            hintText: "Votre commentaire...",
                            filled: true,
                            fillColor: fbGrey,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: () async {
                          if (_commentCtrl.text.isNotEmpty) {
                            try {
                              await _authService.addComment(postId, _commentCtrl.text);
                              _commentCtrl.clear();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur comm: $e")));
                            }
                          }
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleShare(String postId) async {
    await _authService.incrementShares(postId);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lien copié ! Image partagée.")));
  }

  // --- HELPER WIDGETS ---
  Widget _buildCircleButton(IconData icon, VoidCallback onPressed) => Container(
    margin: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: fbGrey, shape: BoxShape.circle),
    child: IconButton(icon: Icon(icon, color: Colors.black, size: 22), onPressed: onPressed),
  );

  Widget _buildPostStats(int likes, int comments, int shares) => Padding(
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
            Text("$likes"),
          ],
        ),
        Text("$comments commentaires • $shares partages"),
      ],
    ),
  );

  Widget _buildInteraction(IconData icon, String label, Color color, VoidCallback onTap) => TextButton.icon(
    onPressed: onTap,
    icon: Icon(icon, color: color),
    label: Text(label, style: TextStyle(color: color)),
  );
}
