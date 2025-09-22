import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../services/directus_service.dart';

class ArticlesProvider extends ChangeNotifier {
  final DirectusService _directusService;

  ArticlesProvider(this._directusService);

  final List<Article> _articles = [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoadedOnce = false;

  List<Article> get articles => List.unmodifiable(_articles);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadArticles({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_hasLoadedOnce && !forceRefresh) return;

    _setLoading(true);
    try {
      final fetched = await _directusService.getArticles();
      _articles
        ..clear()
        ..addAll(fetched);
      _error = null;
      _hasLoadedOnce = true;
    } catch (e) {
      _error = "Impossible de charger les articles";
      if (kDebugMode) {
        debugPrint('ArticlesProvider load error: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await loadArticles(forceRefresh: true);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
