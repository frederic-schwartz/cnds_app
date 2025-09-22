class AppInfo {
  final String appName;
  final String fullVersion;
  final String? packageName;
  final String? buildSignature;

  const AppInfo({
    required this.appName,
    required this.fullVersion,
    this.packageName,
    this.buildSignature,
  });
}
