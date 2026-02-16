import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Nécessaire pour les checks web
import 'dart:io';

import 'auth_service.dart';
import 'feed_page.dart';  // Pour la navigation

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Couleurs du thème
  final Color whiteBg = const Color(0xFFF8F8FF);
  final Color indigoDark = const Color(0xFF1A237E);
  
  // Listes
  final List<String> _roles = ['Producteur', 'Acheteur', 'Acheteur et Producteur', 'Coopérative'];
  final List<String> _communes = ['Kandi', 'Banikoara', 'Segbana', 'Malanville'];

  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  // -- UI STATE --
  bool isLoginMode = true;
  bool _isLoading = false;

  // -- FORM CONTROLLERS --
  final _formKey = GlobalKey<FormState>();

  // Champs communs
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Champs Inscription
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  
  String _selectedRole = 'Producteur';
  String _selectedCommune = 'Kandi';
  
  XFile? _imageFile; // Utilisation de XFile pour compatibilité Web

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  // LOGIQUE DE NAVIGATION
  void _navigateToFeed() {
    // pushAndRemoveUntil vide la pile de navigation.
    // L'utilisateur ne pourra pas faire "retour" pour revenir au login.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const FeedPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isCooperative = _selectedRole == 'Coopérative';

    return Scaffold(
      backgroundColor: whiteBg,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: indigoDark)
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoginMode ? "Connexion" : "Inscription",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: indigoDark),
                ),
                const SizedBox(height: 30),

                if (!isLoginMode) ...[
                  _buildDropdown("Vous êtes ?", Icons.person_pin_rounded, _roles, _selectedRole, (v) {
                    setState(() {
                      _selectedRole = v!;
                      _imageFile = null;
                    });
                  }),
                  if (isCooperative) ...[
                    _buildField("Nom de la coopérative", Icons.business, _nomController),
                  ] else ...[
                    _buildField("Nom", Icons.person, _nomController),
                    _buildField("Prénom", Icons.person_outline, _prenomController),
                    _buildDropdown("Commune", Icons.location_city_rounded, _communes, _selectedCommune, (v) => setState(() => _selectedCommune = v!)),
                  ],
                ],

                  _buildField("Téléphone", Icons.phone_android, _phoneController, type: TextInputType.phone),
                _buildField("Mot de passe", Icons.lock_outline, _passwordController, obscure: true),

                if (!isLoginMode) ...[
                  const SizedBox(height: 10),
                  Text(isCooperative ? "Carte de coopérative" : "Photo CIP",
                      style: TextStyle(color: indigoDark.withOpacity(0.7), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _buildImagePicker(),
                ],

                const SizedBox(height: 40),

                // BOUTON DE CONNEXION / INSCRIPTION
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: indigoDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                  ),
                    onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      try {
                        if (isLoginMode) {
                          // --- CONNEXION ---
                          await _authService.signIn(
                            phone: _phoneController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                          _navigateToFeed();
                        } else {
                          // --- INSCRIPTION ---
                          bool isCooperative = _selectedRole == 'Coopérative';
                          
                          await _authService.signUp(
                            phone: _phoneController.text.trim(),
                            password: _passwordController.text.trim(),
                            role: _selectedRole,
                            name: _nomController.text.trim(),
                            prenom: isCooperative ? null : _prenomController.text.trim(),
                            commune: _selectedCommune,
                            imageFile: _imageFile, // On passe XFile directement
                          );
                          _navigateToFeed();
                        }
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Opération échouée : $e"), backgroundColor: Colors.red));
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    }
                  },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                      isLoginMode ? "SE CONNECTER" : "S'INSCRIRE",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => isLoginMode = !isLoginMode),
                    child: Text(
                      isLoginMode ? "Pas de compte ? Créer un compte" : "Déjà un compte ? Se connecter",
                      style: TextStyle(color: indigoDark, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION (DESIGN BLANC/INDIGO) ---

  Widget _buildField(String label, IconData icon, TextEditingController ctrl, {bool obscure = false, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: type,
        style: TextStyle(color: indigoDark),
        validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: indigoDark.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: indigoDark),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: indigoDark.withOpacity(0.1))
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: indigoDark, width: 2)
          ),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.redAccent)
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, IconData icon, List<String> items, String value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: Colors.white,
        style: TextStyle(color: indigoDark),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: indigoDark.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: indigoDark),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: indigoDark.withOpacity(0.1))
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: indigoDark.withOpacity(0.1))),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () => _showPicker(),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: indigoDark.withOpacity(0.2)),
        ),
        child: _imageFile == null
            ? Icon(Icons.add_a_photo_outlined, color: indigoDark, size: 35)
            : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: kIsWeb
                    ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                    : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
              ),
      ),
    );
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
              leading: Icon(Icons.photo, color: indigoDark),
              title: Text("Galerie", style: TextStyle(color: indigoDark)),
              onTap: () { _pickImage(ImageSource.gallery); Navigator.pop(ctx); }
          ),
          ListTile(
              leading: Icon(Icons.camera_alt, color: indigoDark),
              title: Text("Appareil photo", style: TextStyle(color: indigoDark)),
              onTap: () { _pickImage(ImageSource.camera); Navigator.pop(ctx); }
          ),
        ]),
      ),
    );
  }
}

