import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appName = _packageInfo?.appName ?? 'CNDS App';
    final version = _packageInfo == null
        ? 'Chargement...'
        : '${_packageInfo!.version}+${_packageInfo!.buildNumber}';
    final packageName = _packageInfo?.packageName;
    final buildSignature = _packageInfo?.buildSignature;

    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: SingleChildScrollView(
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
              appName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Version $version',
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
                      value: appName,
                    ),
                    _InfoRow(
                      label: 'Version complète',
                      value: version,
                    ),
                    if (packageName != null && packageName.isNotEmpty)
                      _InfoRow(
                        label: 'Identifiant du package',
                        value: packageName,
                      ),
                    if (buildSignature != null && buildSignature.isNotEmpty)
                      _InfoRow(
                        label: 'Signature',
                        value: buildSignature,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '© $currentYear ONLINE404.com',
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
