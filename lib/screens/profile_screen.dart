import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/directus_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final directus = context.read<DirectusService>();
      final user = await directus.getCurrentUser();
      Map<String, dynamic>? profile;
      try {
        final profileResponse = await directus.getUserProfile();
        final data = profileResponse['data'] as List?;
        if (data != null && data.isNotEmpty) {
          profile = data.first as Map<String, dynamic>;
        }
      } catch (e) {
        // ignore profile errors but keep user
      }
      if (!mounted) return;
      setState(() {
        _user = user['data'] as Map<String, dynamic>?;
        _profile = profile;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Impossible de charger ton profil.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadProfile,
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: _buildBody(authProvider),
    );
  }

  Widget _buildBody(AuthProvider authProvider) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final user = _user;
    final profile = _profile;
    final firstName = user?['first_name']?.toString();
    final lastName = user?['last_name']?.toString();
    final status = user?['status']?.toString();
    final lastAccess = user?['last_access']?.toString();
    final created = user?['date_created']?.toString();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _ProfileHeader(
          nickname: authProvider.userNickname,
          email: authProvider.userEmail,
        ),
        const SizedBox(height: 24),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informations du compte',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Email',
                  value:
                      authProvider.userEmail ??
                      user?['email']?.toString() ??
                      '-',
                ),
                _InfoRow(
                  label: 'Nom d\'utilisateur',
                  value:
                      authProvider.userNickname ??
                      profile?['nickname']?.toString() ??
                      '-',
                ),
                if (firstName != null && firstName.isNotEmpty)
                  _InfoRow(label: 'Prénom', value: firstName),
                if (lastName != null && lastName.isNotEmpty)
                  _InfoRow(label: 'Nom', value: lastName),
                if (status != null && status.isNotEmpty)
                  _InfoRow(label: 'Statut', value: status),
                if (lastAccess != null && lastAccess.isNotEmpty)
                  _InfoRow(label: 'Dernier accès', value: lastAccess),
                if (created != null && created.isNotEmpty)
                  _InfoRow(label: 'Compte créé le', value: created),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Préférences',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _InfoRow(label: 'Notifications', value: 'Actives'),
                _InfoRow(label: 'Langue', value: 'Français'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String? nickname;
  final String? email;

  const _ProfileHeader({this.nickname, this.email});

  @override
  Widget build(BuildContext context) {
    final initials = (nickname ?? email ?? '?').isNotEmpty
        ? (nickname ?? email ?? '?')[0].toUpperCase()
        : '?';

    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.deepPurple,
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nickname ?? 'Utilisateur',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email ?? 'Adresse email non renseignée',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
