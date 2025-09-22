import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aide')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _Section(
            title: 'Besoin d\'aide ?',
            description:
                'Consulte les réponses aux questions fréquentes ou contacte notre équipe de support.',
          ),
          _HelpfulTile(
            icon: Icons.help_outline,
            title: 'FAQ',
            subtitle:
                'Retrouve les réponses aux demandes courantes concernant les réservations et ton compte.',
          ),
          _HelpfulTile(
            icon: Icons.chat_bubble_outline,
            title: 'Support par chat',
            subtitle:
                'Disponible du lundi au vendredi de 9h à 18h directement dans l\'application.',
          ),
          _HelpfulTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'support@cnds.fr',
          ),
          _HelpfulTile(
            icon: Icons.phone_outlined,
            title: 'Téléphone',
            subtitle: '+33 1 23 45 67 89',
          ),
          SizedBox(height: 24),
          _Section(
            title: 'Conseils',
            description:
                '• Vérifie que ton profil est complet pour faciliter les réservations.\n'
                '• Utilise la fonction de rafraîchissement sur la page d\'accueil pour charger les derniers articles.\n'
                '• Contacte-nous sans hésiter pour toute question ou suggestion.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String description;

  const _Section({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(description, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _HelpfulTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HelpfulTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
