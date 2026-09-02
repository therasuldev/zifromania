import 'data_exception.dart';
import 'domain_exception.dart';
import 'app_exception.dart';

abstract class ErrorHandler {
  static String mapToMessage(AppException exception) {
    return switch (exception) {
      ServerException(statusCode: 401) => 'Sessiyanızın vaxtı bitdi.',
      ServerException(statusCode: 404) => 'Məlumat tapılmadı.',
      ServerException(statusCode: 500) => 'Serverdə xəta baş verdi.',
      ServerException(:final message) => message,
      NetworkException() => 'İnternet bağlantınızı yoxlayın.',
      FileLoadException() => 'Fayl oxunarkən xəta baş verdi.',
      InvalidJsonException() => 'Məlumat emal edilə bilmədi.',
      DailyLimitReachedException() => 'Bu günlük limitiniz bitdi.',
      InsufficientCoinsException() => 'Bu əməliyyat üçün balansa ehtiyac var.',
      UnknownException() => 'Bilinməyən xəta baş verdi.',
      _ => () {
          assert(false, 'ErrorHandler.mapToMessage: unmapped exception type ${exception.runtimeType}');
          return 'Bilinməyən xəta baş verdi.';
        }(),
    };
  }
}
