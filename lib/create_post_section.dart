import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Nécessaire pour les checks web
import 'dart:io';

import 'auth_service.dart';

class CreatePostSection extends StatefulWidget {
  const CreatePostSection({super.key});

  @override
  State<CreatePostSection> createState() => _CreatePostSectionState();
}

class _CreatePostSectionState extends State<CreatePostSection> {
  final AuthService _authService = AuthService();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile; // Utilisation de XFile pour compatibilité Web/Mobile
  bool _isPosting = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  Future<void> _createPost() async {
    String content = _contentController.text.trim();
    if (content.isEmpty && _imageFile == null) return;

    setState(() => _isPosting = true);
    try {
      await _authService.addPost(
        content: content,
        imageFile: _imageFile, // On passe XFile directement maintenant
      );
      
      if (mounted) {
        _contentController.clear();
        setState(() => _imageFile = null);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Publication ajoutée !")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  Widget _buildImagePreview() {
    if (kIsWeb) {
      return Image.network(_imageFile!.path, height: 150, fit: BoxFit.cover);
    } else {
      return Image.file(File(_imageFile!.path), height: 150, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: "Quoi de neuf ?",
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    // borderRadius: BorderRadius.circular(20), 
                  ),
                ),
              ),
              IconButton(
                onPressed: _isPosting ? null : _createPost,
                icon: const Icon(Icons.send, color: Colors.blue),
              ),
            ],
          ),
          if (_imageFile != null) ...[
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.topRight,
              children: [
                _buildImagePreview(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => setState(() => _imageFile = null),
                ),
              ],
            ),
          ],
          if (_isPosting) 
            const LinearProgressIndicator()
          else ...[
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library, color: Colors.green),
                  label: const Text("Photo/Vidéo"),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}
