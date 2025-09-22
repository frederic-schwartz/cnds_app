import 'package:flutter/foundation.dart';
import '../services/directus_service.dart';

class SimpleAuthProvider extends ChangeNotifier {
  final DirectusService _directusService;

  SimpleAuthProvider(this._directusService);

  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  String? _userNickname;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasValidProfile => _userNickname != null && _userNickname!.isNotEmpty;
  String? get userNickname => _userNickname;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      // 1. Connexion
      await _directusService.login(email, password);
      _isLoggedIn = true;

      // 2. Vérifier le profil
      await _checkProfile();

      return true;
    } catch (e) {
      _setError('Connexion échouée');
      _isLoggedIn = false;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _checkProfile() async {
    try {
      final profileResponse = await _directusService.getUserProfile();
      final profiles = profileResponse['data'] as List;

      if (profiles.isNotEmpty) {
        final profile = profiles.first;
        _userNickname = profile['nickname'] as String?;
      } else {
        _userNickname = null;
      }
    } catch (e) {
      print('Erreur vérification profil: $e');
      _userNickname = null;
    }
  }

  Future<bool> createProfile(String nickname) async {
    _setLoading(true);
    _setError(null);

    try {
      await _directusService.createOrUpdateProfile(nickname);
      _userNickname = nickname;
      return true;
    } catch (e) {
      _setError('Erreur création profil');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _directusService.logout();
    _isLoggedIn = false;
    _userNickname = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      _isLoggedIn = await _directusService.isLoggedIn();
      if (_isLoggedIn) {
        await _checkProfile();
      }
    } catch (e) {
      _isLoggedIn = false;
      _userNickname = null;
    } finally {
      _setLoading(false);
    }
  }
}