import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'feedPage.dart'; // Importation corrigée selon ton nom de fichier

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoginMode = true;
  final _formKey = GlobalKey<FormState>();

  // Couleurs du thème
  final Color whiteBg = const Color(0xFFF8F8FF);
  final Color indigoDark = const Color(0xFF1A237E);

  final List<String> _roles = ['Producteur', 'Acheteur', 'Acheteur et Producteur', 'Coopérative'];
  final List<String> _communes = ['Kandi', 'Banikoara', 'Segbana', 'Malanville'];

  String _selectedRole = 'Producteur';
  String _selectedCommune = 'Kandi';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // LOGIQUE DE NAVIGATION VERS LE VRAI FIL D'ACTUALITÉ
  void _navigateToFeed() {
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

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: indigoDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _navigateToFeed();
                    }
                  },
                  child: Text(
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

  // --- WIDGETS DE CONSTRUCTION ---

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
            : ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_imageFile!, fit: BoxFit.cover)),
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