import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, String> get _headers {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de l\'inscription: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['data']['access_token'], data['data']['refresh_token']);
        return data;
      } else {
        throw Exception('Erreur lors de la connexion: ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
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
      await _saveTokens(data['data']['access_token'], data['data']['refresh_token']);
      return data;
    } else {
      throw Exception('Erreur lors du rafraîchissement du token: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      await _loadTokens();
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: _headers,
      );

      print('getCurrentUser response status: ${response.statusCode}');
      print('getCurrentUser response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await refreshTokens();
        return getCurrentUser();
      } else {
        throw Exception('Erreur lors de la récupération de l\'utilisateur: ${response.body}');
      }
    } catch (e) {
      print('getCurrentUser error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final user = await getCurrentUser();
      final userId = user['data']['id'];

      // Essayons différentes approches
      final response = await http.get(
        Uri.parse('$_baseUrl/items/profiles?filter={"user_id":{"_eq":"$userId"}}'),
        headers: _headers,
      );

      print('getUserProfile NEW response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        await refreshTokens();
        return getUserProfile();
      } else {
        throw Exception('Status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('getUserProfile error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createOrUpdateProfile(String nickname) async {
    try {
      final user = await getCurrentUser();
      final userId = user['data']['id'];
      print('Creating profile for userId: $userId');

      final profileData = await getUserProfile();
      final profiles = profileData['data'] as List;

      if (profiles.isNotEmpty) {
        final profile = profiles.first;
        final profileUserId = profile['user_id'];
        print('Updating existing profile for user: $profileUserId');
        final response = await http.patch(
          Uri.parse('$_baseUrl/items/profiles/$profileUserId'),
          headers: _headers,
          body: jsonEncode({'nickname': nickname}),
        );

        print('Update profile response: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          throw Exception('Erreur mise à jour profil');
        }
      } else {
        print('Creating new profile with nickname: "$nickname"');
        final response = await http.post(
          Uri.parse('$_baseUrl/items/profiles'),
          headers: _headers,
          body: jsonEncode({
            'user_id': userId,
            'nickname': nickname.isEmpty ? null : nickname,
          }),
        );

        print('Create profile response: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 204) {
          // Création réussie, pas de contenu retourné
          // Récupérons le profil créé
          await Future.delayed(const Duration(milliseconds: 100)); // Petit délai
          return await getUserProfile();
        } else if (response.statusCode == 403) {
          throw Exception('Pas d\'autorisation pour créer un profil');
        } else {
          throw Exception('Erreur création profil');
        }
      }
    } catch (e) {
      print('createOrUpdateProfile error: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    final user = await getCurrentUser();
    final userId = user['data']['id'];

    final response = await http.delete(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      await _clearTokens();
    } else {
      throw Exception('Erreur lors de la suppression du compte: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getProducts() async {
    await _loadTokens();
    final response = await http.get(
      Uri.parse('$_baseUrl/items/products'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      await refreshTokens();
      return getProducts();
    } else {
      throw Exception('Erreur lors de la récupération des produits: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> makeReservation(String productId) async {
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
    } else if (response.statusCode == 401) {
      await refreshTokens();
      return makeReservation(productId);
    } else {
      throw Exception('Erreur lors de la réservation: ${response.body}');
    }
  }

  Future<bool> isLoggedIn() async {
    await _loadTokens();
    return _accessToken != null;
  }
}