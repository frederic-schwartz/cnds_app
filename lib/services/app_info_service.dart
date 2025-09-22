import 'package:package_info_plus/package_info_plus.dart';

import '../models/app_info.dart';

class AppInfoService {
  Future<AppInfo> loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = '${packageInfo.version}+${packageInfo.buildNumber}';

    return AppInfo(
      appName: packageInfo.appName,
      fullVersion: version,
      packageName: packageInfo.packageName.isEmpty ? null : packageInfo.packageName,
      buildSignature: packageInfo.buildSignature.isEmpty ? null : packageInfo.buildSignature,
    );
  }
}
