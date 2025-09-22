import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/about_provider.dart';
import '../providers/articles_provider.dart';
import '../providers/auth_provider.dart';
import '../services/app_info_service.dart';
import 'about_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticlesProvider>().loadArticles();
    });
  }

  Widget _buildAvatar(String? nickname) {
    final initial = nickname?.isNotEmpty == true
        ? nickname![0].toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.deepPurple,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CNDS App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Drawer(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAvatar(authProvider.userNickname),
                          const SizedBox(height: 12),
                          Text(
                            authProvider.userNickname ?? 'Utilisateur',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authProvider.userEmail ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Mon profil'),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigation vers profil
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('Aide'),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigation vers aide
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('À propos'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider(
                                create: (_) =>
                                    AboutProvider(AppInfoService())
                                      ..loadAppInfo(),
                                child: const AboutScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Déconnexion',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          await authProvider.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      body: Consumer2<AuthProvider, ArticlesProvider>(
        builder: (context, authProvider, articlesProvider, child) {
          return SafeArea(child: _buildBody(authProvider, articlesProvider));
        },
      ),
    );
  }

  Widget _buildBody(
    AuthProvider authProvider,
    ArticlesProvider articlesProvider,
  ) {
    if (articlesProvider.isLoading && articlesProvider.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (articlesProvider.error != null && articlesProvider.articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                articlesProvider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    articlesProvider.loadArticles(forceRefresh: true),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: articlesProvider.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildWelcomeCard(authProvider),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Articles disponibles',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (articlesProvider.isLoading) const LinearProgressIndicator(),
          if (articlesProvider.articles.isEmpty) _buildEmptyArticlesState(),
          ...articlesProvider.articles.map(_buildArticleCard),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(AuthProvider authProvider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 32,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue ${authProvider.userNickname ?? ''}!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Découvre les derniers articles disponibles et effectue tes réservations en un clin d\'œil.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyArticlesState() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.inbox_outlined, size: 32, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aucun article disponible pour le moment',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reviens plus tard ou tire pour rafraîchir la liste.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    final hasDiscount =
        article.newSellingPrice != null && article.newSellingPrice! > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Référence : ${article.number}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hasDiscount)
                      Text(
                        _formatPrice(article.sellingPrice),
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.red,
                        ),
                      ),
                    Text(
                      _formatPrice(
                        hasDiscount
                            ? article.newSellingPrice!
                            : article.sellingPrice,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (article.description != null && article.description!.isNotEmpty)
              Text(
                article.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
            if (article.description != null && article.description!.isNotEmpty)
              const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.inventory_outlined, size: 18),
                  label: Text('Stock: ${article.stock?.toString() ?? '-'}'),
                ),
                Chip(
                  avatar: const Icon(Icons.layers_outlined, size: 18),
                  label: Text(
                    article.multipleItems
                        ? 'Plusieurs exemplaires'
                        : 'Pièce unique',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price % 1 == 0) {
      return '${price.toStringAsFixed(0)} €';
    }
    return '${price.toStringAsFixed(2)} €';
  }
}
