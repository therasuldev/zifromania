enum AppErrorType {
  dailyLimitReached,
  notEnoughCoins,
  fileLoadError,
  invalidJson,
  networkError,
  unknown,
}

class AppException implements Exception {
  final AppErrorType type;
  final String message;

  AppException(this.type, this.message);

  @override
  String toString() => message;
}
