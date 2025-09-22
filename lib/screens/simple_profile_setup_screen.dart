import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/simple_auth_provider.dart';
import 'simple_home_screen.dart';

class SimpleProfileSetupScreen extends StatefulWidget {
  const SimpleProfileSetupScreen({super.key});

  @override
  State<SimpleProfileSetupScreen> createState() => _SimpleProfileSetupScreenState();
}

class _SimpleProfileSetupScreenState extends State<SimpleProfileSetupScreen> {
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un nom d\'utilisateur')),
      );
      return;
    }

    final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
    final success = await authProvider.createProfile(_nicknameController.text.trim());

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SimpleHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Erreur'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurer le profil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choisissez un nom d\'utilisateur',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Consumer<SimpleAuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _saveProfile,
                  child: authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Continuer'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}