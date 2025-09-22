import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_info.dart';
import '../providers/about_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: Consumer<AboutProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.appInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final appInfo = provider.appInfo;
          if (appInfo == null) {
            return const SizedBox.shrink();
          }

          return _AboutContent(appInfo: appInfo);
        },
      ),
    );
  }
}

class _AboutContent extends StatelessWidget {
  final AppInfo appInfo;

  const _AboutContent({required this.appInfo});

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.info_outline,
            size: 80,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 16),
          Text(
            appInfo.appName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Version ${appInfo.fullVersion}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Le CNDS App permet aux utilisateurs de gérer leurs réservations et leur profil en toute simplicité. '
            'Cette page affichera toujours la version exacte installée sur votre appareil.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Nom de l\'application',
                    value: appInfo.appName,
                  ),
                  _InfoRow(
                    label: 'Version complète',
                    value: appInfo.fullVersion,
                  ),
                  if (appInfo.packageName != null)
                    _InfoRow(
                      label: 'Identifiant du package',
                      value: appInfo.packageName!,
                    ),
                  if (appInfo.buildSignature != null)
                    _InfoRow(
                      label: 'Signature',
                      value: appInfo.buildSignature!,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '© $currentYear CNDS. Tous droits réservés.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
