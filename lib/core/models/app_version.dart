class AppVersion {
  final String currentVersion;
  final String minimumRequiredVersion;
  final bool forceUpdate;

  AppVersion({
    required this.currentVersion,
    required this.minimumRequiredVersion,
    required this.forceUpdate,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      currentVersion: json['currentVersion'] as String,
      minimumRequiredVersion: json['minimumRequiredVersion'] as String,
      forceUpdate: json['forceUpdate'] as bool,
    );
  }
}
