import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

class DirectusService {
  static const String _baseUrl = 'https://api-cnds-7d4e5a.online404.com';
  String? _accessToken;
  String? _refreshToken;

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    _accessToken = null;
    _refreshToken = null;
  }

  Future<void> clearSession() async {
    await _clearTokens();
  }

  Map<String, String> get _headers {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {'success': true};
      }
    } else {
      throw Exception('Erreur lors de l\'inscription: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(
          data['data']['access_token'],
          data['data']['refresh_token'],
        );
        return data;
      } else {
        throw Exception('Erreur lors de la connexion: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _loadTokens();
    if (_refreshToken != null) {
      await http.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': _refreshToken}),
      );
    }
    await _clearTokens();
  }

  Future<Map<String, dynamic>> refreshTokens() async {
    await _loadTokens();
    if (_refreshToken == null) {
      throw Exception('Aucun refresh token disponible');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(
        data['data']['access_token'],
        data['data']['refresh_token'],
      );
      return data;
    } else {
      await _clearTokens();
      throw Exception(
        'Erreur lors du rafraîchissement du token: ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> getCurrentUser({bool retry = false}) async {
    try {
      await _loadTokens();
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401 && !retry) {
        await refreshTokens();
        return getCurrentUser(retry: true);
      } else {
        if (response.statusCode == 401) {
          await _clearTokens();
        }
        throw Exception(
          'Erreur lors de la récupération de l\'utilisateur: ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserProfile({bool retry = false}) async {
    try {
      final user = await getCurrentUser();
      final userId = user['data']['id'];

      // Essayons différentes approches
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/items/profiles?filter={"user_id":{"_eq":"$userId"}}',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 401 && !retry) {
        await refreshTokens();
        return getUserProfile(retry: true);
      } else {
        throw Exception('Status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createOrUpdateProfile(
    String nickname, {
    bool retry = false,
  }) async {
    try {
      final user = await getCurrentUser();
      final userId = user['data']['id'];

      final profileData = await getUserProfile();
      final profiles = profileData['data'] as List;

      if (profiles.isNotEmpty) {
        final profile = profiles.first;
        final profileUserId = profile['user_id'];
        final response = await http.patch(
          Uri.parse('$_baseUrl/items/profiles/$profileUserId'),
          headers: _headers,
          body: jsonEncode({'nickname': nickname}),
        );
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 401 && !retry) {
          await refreshTokens();
          return createOrUpdateProfile(nickname, retry: true);
        } else {
          throw Exception('Erreur mise à jour profil');
        }
      } else {
        final response = await http.post(
          Uri.parse('$_baseUrl/items/profiles'),
          headers: _headers,
          body: jsonEncode({
            'user_id': userId,
            'nickname': nickname.isEmpty ? null : nickname,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 204) {
          // Création réussie, pas de contenu retourné
          // Récupérons le profil créé
          await Future.delayed(
            const Duration(milliseconds: 100),
          ); // Petit délai
          return await getUserProfile();
        } else if (response.statusCode == 401 && !retry) {
          await refreshTokens();
          return createOrUpdateProfile(nickname, retry: true);
        } else if (response.statusCode == 403) {
          throw Exception('Pas d\'autorisation pour créer un profil');
        } else if (response.statusCode == 400) {
          // Analyser l'erreur 400 pour détecter le cas du nickname non unique
          try {
            final errorData = jsonDecode(response.body);
            final errors = errorData['errors'] as List?;
            if (errors != null && errors.isNotEmpty) {
              final error = errors.first;
              final code = error['extensions']?['code'];
              if (code == 'RECORD_NOT_UNIQUE' &&
                  error['extensions']?['field'] == 'nickname') {
                throw Exception(
                  'Ce nickname est déjà utilisé. Choisis-en un autre !',
                );
              }
            }
          } catch (e) {
            if (e.toString().contains('Ce nickname est déjà utilisé')) {
              rethrow;
            }
          }
          throw Exception('Erreur lors de la création du profil');
        } else {
          throw Exception('Erreur création profil');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount({bool retry = false}) async {
    await _loadTokens();
    final user = await getCurrentUser();
    final userId = user['data']['id'];

    final response = await http.delete(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      await _clearTokens();
    } else if (response.statusCode == 401 && !retry) {
      await refreshTokens();
      await deleteAccount(retry: true);
    } else {
      throw Exception(
        'Erreur lors de la suppression du compte: ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> getProducts({bool retry = false}) async {
    await _loadTokens();
    final response = await http.get(
      Uri.parse('$_baseUrl/items/products'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401 && !retry) {
      await refreshTokens();
      return getProducts(retry: true);
    } else {
      throw Exception(
        'Erreur lors de la récupération des produits: ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> makeReservation(
    String productId, {
    bool retry = false,
  }) async {
    final user = await getCurrentUser();
    final userId = user['data']['id'];

    final response = await http.post(
      Uri.parse('$_baseUrl/items/reservations'),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'product_id': productId,
        'status': 'pending',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401 && !retry) {
      await refreshTokens();
      return makeReservation(productId, retry: true);
    } else {
      throw Exception('Erreur lors de la réservation: ${response.body}');
    }
  }

  Future<bool> isLoggedIn() async {
    await _loadTokens();
    return _accessToken != null && _refreshToken != null;
  }

  Future<List<Article>> getArticles({bool retry = false}) async {
    await _loadTokens();
    final response = await http.get(
      Uri.parse('$_baseUrl/items/articles?fields=*,articles_files.*'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final data = payload['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401 && !retry) {
      await refreshTokens();
      return getArticles(retry: true);
    } else {
      throw Exception(
        'Erreur lors de la récupération des articles: ${response.body}',
      );
    }
  }
}
