import 'package:flutter/foundation.dart';

import '../models/app_info.dart';
import '../services/app_info_service.dart';

class AboutProvider extends ChangeNotifier {
  final AppInfoService _service;

  AboutProvider(this._service);

  AppInfo? _appInfo;
  bool _isLoading = false;
  String? _error;

  AppInfo? get appInfo => _appInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAppInfo() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appInfo = await _service.loadAppInfo();
    } catch (e) {
      _error = 'Impossible de charger les informations de l\'application.';
      _appInfo = null;
      if (kDebugMode) {
        debugPrint('AboutProvider error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
