import 'package:flutter/foundation.dart';

import '../services/directus_service.dart';

class AuthProvider extends ChangeNotifier {
  final DirectusService _directusService;

  AuthProvider(this._directusService);

  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  String? _userNickname;
  String? _userEmail;
  bool _isCheckingSession = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasValidProfile => _userNickname != null && _userNickname!.isNotEmpty;
  String? get userNickname => _userNickname;
  String? get userEmail => _userEmail;
  bool get isCheckingSession => _isCheckingSession;

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
      _userEmail = email;

      // 2. Vérifier le profil
      await _checkProfile();

      return true;
    } catch (e) {
      _setError('Connexion échouée');
      _isLoggedIn = false;
      await _directusService.clearSession();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      await _directusService.register(email, password);
      return true;
    } catch (e) {
      _setError('Inscription échouée');
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
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _directusService.logout();
    _isLoggedIn = false;
    _userNickname = null;
    _userEmail = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _isCheckingSession = true;
    notifyListeners();
    try {
      final hasValidTokens = await _directusService.isLoggedIn();

      if (!hasValidTokens) {
        _isLoggedIn = false;
        _userNickname = null;
        _userEmail = null;
        return;
      }

      try {
        final user = await _directusService.getCurrentUser();
        _userEmail = user['data']['email'] as String?;
        _isLoggedIn = true;
        await _checkProfile();
      } catch (_) {
        await _directusService.clearSession();
        _isLoggedIn = false;
        _userNickname = null;
        _userEmail = null;
      }
    } catch (e) {
      _isLoggedIn = false;
      _userNickname = null;
      _userEmail = null;
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }
}
