import 'package:flutter/material.dart';
import 'login_page.dart';
<<<<<<< HEAD
import 'feedPage.dart'; // Corrigé ici : correspond exactement à ton fichier
=======
// N'oublie pas d'importer ton fichier feed_page.dart si tu l'as séparé
import 'feed_page.dart';
>>>>>>> 7bf8281 (Add likes, comments, shares, search, and logout functionality with fixes)

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedUserType;
  String _selectedCommune = 'Kandi';
  final List<String> _communes = ['Kandi', 'Banikoara', 'Segbana'];

  final Color whiteBg = const Color(0xFFF8F8FF);
  final Color indigoDark = const Color(0xFF1A237E);

  // NAVIGATION VERS LE FIL
  void _navigateToFeed() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const FeedPage()), // Vérifie que la classe dans feesPage s'appelle FeedPage
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: indigoDark),
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
                  "Inscription",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: indigoDark)
                ),
                const SizedBox(height: 30),

                _buildDropdown(
                  "Vous êtes ?",
                  Icons.person_pin_rounded,
                  ['Producteur', 'Acheteur', 'Coopérative'],
                  _selectedUserType,
                  (v) => setState(() => _selectedUserType = v)
                ),

                if (_selectedUserType != null) ...[
                  _buildDropdown("Commune", Icons.location_city_rounded, _communes, _selectedCommune, (v) => setState(() => _selectedCommune = v!)),
                  _buildField("Nom", Icons.person_outline),
                  _buildField("Téléphone", Icons.phone_android, type: TextInputType.phone),
                  _buildField("Mot de passe", Icons.lock_outline, obscure: true),

                  const SizedBox(height: 30),

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
                    child: const Text("S'INSCRIRE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],

                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage())
                    ),
                    child: Text(
                        "Déjà inscrit ? Connexion",
                        style: TextStyle(color: indigoDark, fontWeight: FontWeight.w600)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---
  Widget _buildField(String label, IconData icon, {bool obscure = false, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
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
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, IconData icon, List<String> items, String? value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: Colors.white,
        style: TextStyle(color: indigoDark),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "Veuillez choisir une option" : null,
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
        ),
      ),
    );
  }
}
<<<<<<< HEAD
// LA CLASSE VIDE A ÉTÉ SUPPRIMÉE ICI POUR ÉVITER LES CONFLITS
=======

>>>>>>> 7bf8281 (Add likes, comments, shares, search, and logout functionality with fixes)
