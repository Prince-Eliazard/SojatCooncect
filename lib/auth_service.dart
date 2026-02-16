import 'dart:io';
import 'dart:convert'; // Pour base64
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // Pour XFile

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- INSCRIPTION ---
  Future<User?> signUp({
    required String phone, // On utilise le téléphone comme identifiant
    required String password,
    required String role, 
    required String name,
    String? prenom,
    String? email, // Optionnel maintenant
    required String commune,
    XFile? imageFile, 
  }) async {
    try {
      // Astuce : On crée un email unique basé sur le téléphone pour Firebase Auth
      // car Firebase Auth "Phone" fonctionne par SMS (sans mot de passe).
      // On crée un email fictif car Firebase Auth "Email/Password" exige un email
      // Ex: "+22997000000@sodjaconnect.app"
      // On nettoie le numéro pour enlever les espaces éventuels
      String cleanPhone = phone.replaceAll(' ', '');
      String fakeEmail = "$cleanPhone@sodjaconnect.app";
      print("Tentative inscription: Email=$fakeEmail, MDP=$password"); // DEBUG

      // 1. Créer le compte Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );
      print("Compte Auth créé avec succès: ${result.user?.uid}"); // DEBUG
      User? user = result.user;

      if (user != null) {
        String? imageBase64;

        // 2. Conversion de la photo en base64 si présente (au lieu de Storage)
        if (imageFile != null) {
          try {
            final bytes = await imageFile.readAsBytes();
            imageBase64 = base64Encode(bytes);
            print("Image convertie en base64 (${imageBase64.length} caractères)");
          } catch (e) {
            print("Erreur conversion photo: $e");
          }
        }

        // 3. Sauvegarder les infos supplémentaires dans Firestore
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email ?? '', 
          'role': role,
          'nom': name,
          'prenom': prenom ?? '',
          'telephone': phone,
          'commune': commune,
          'photo_base64': imageBase64 ?? '', // Stockage en base64
          'date_inscription': FieldValue.serverTimestamp(),
          'est_active': true,
        });

        // 4. Mettre à jour le profil Firebase Auth (nom seulement, pas de photo URL)
        await user.updateDisplayName("$name ${prenom ?? ''}");

        return user;
      }
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs Firebase
      throw e.message ?? "Une erreur est survenue lors de l'inscription.";
    } catch (e) {
      throw "Erreur inconnue: $e";
    }
    return null;
  }

  // --- CONNEXION ---
  Future<User?> signIn({required String phone, required String password}) async {
    try {
      String fakeEmail = "$phone@sodjaconnect.app";
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Erreur de connexion.";
    }
  }

  // --- DÉCONNEXION ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- RÉCUPÉRER L'UTILISATEUR COURANT ---
  User? get currentUser => _auth.currentUser;

  // --- RÉCUPÉRER LES DONNÉES FIRESTORE ---
  // --- GESTION DES POSTS (FIL D'ACTUALITÉ) ---
  
  // 1. Créer une publication
  Future<void> addPost({required String content, XFile? imageFile}) async {
    User? user = currentUser;
    if (user == null) throw "Vous devez être connecté pour publier.";

    String? imageBase64;
    
    // Conversion de l'image du post en base64 si présente
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      imageBase64 = base64Encode(bytes);
      print("Image post convertie en base64 (${imageBase64.length} caractères)");
    }

    // Récupérer les infos de l'utilisateur pour les mettre dans le post
    DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
    
    String userName = 'Utilisateur'; // Valeur par défaut
    String userPhoto = '';

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>?; // Cast sûr
      if (data != null) {
        userName = data['nom'] ?? 'Utilisateur';
        userPhoto = data['photo_base64'] ?? ''; // Récupération du base64
      }
    } else {
      print("Attention: Profil utilisateur introuvable pour ${user.uid}");
    }

    await _db.collection('posts').add({
      'authorId': user.uid,
      'authorName': userName,
      'authorPhoto': userPhoto,
      'content': content,
      'imageBase64': imageBase64,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [], 
      'commentCount': 0,
      'shares': 0,
    });
  }

  // 2. Lire le fil d'actualité (Temps réel)
  Stream<QuerySnapshot> getPostsStream({String searchQuery = ""}) {
    if (searchQuery.isEmpty) {
      return _db.collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      // Recherche simple par préfixe (insensible à la casse si possible, mais Firestore est brut)
      // On convertit en minuscule pour aider un peu si le contenu est normalisé
      return _db.collection('posts')
          .where('content', isGreaterThanOrEqualTo: searchQuery)
          .where('content', isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .snapshots();
    }
  }

  // 3. Liker/Unliker un post
  Future<void> toggleLike(String postId, dynamic currentLikes) async {
    User? user = currentUser;
    if (user == null) return;

    DocumentReference postRef = _db.collection('posts').doc(postId);
    List<dynamic> likesList = [];

    // Sécurité: Si currentLikes n'est pas une liste (vieux posts), on le convertit
    if (currentLikes is List) {
      likesList = currentLikes;
    }

    if (likesList.contains(user.uid)) {
      print("Unlike post: $postId");
      await postRef.update({
        'likes': FieldValue.arrayRemove([user.uid])
      });
    } else {
      print("Like post: $postId");
      // Si c'est un vieux post où 'likes' était un nombre, on l'écrase par une liste
      if (currentLikes is! List) {
        await postRef.update({
          'likes': [user.uid]
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([user.uid])
        });
      }
    }
  }

  // 4. Ajouter un commentaire
  Future<void> addComment(String postId, String text) async {
    User? user = currentUser;
    if (user == null) return;

    // Récupérer les infos de l'utilisateur
    DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
    String userName = 'Anonyme';
    if (userDoc.exists) {
      userName = (userDoc.data() as Map<String, dynamic>)['nom'] ?? 'Anonyme';
    }

    await _db.collection('posts').doc(postId).collection('comments').add({
      'userId': user.uid,
      'userName': userName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Incrémenter le compteur de commentaires sur le post
    await _db.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(1)
    });
  }

  // 5. Streams pour les commentaires
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return _db.collection('posts').doc(postId).collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 6. Incrémenter les partages
  Future<void> incrementShares(String postId) async {
    await _db.collection('posts').doc(postId).update({
      'shares': FieldValue.increment(1)
    });
  }
}
