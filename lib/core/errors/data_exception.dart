import 'package:zifromania/core/errors/app_exception.dart';

sealed class DataException extends AppException {
  const DataException(super.message, {super.error, super.stackTrace});
}

class ServerException extends DataException {
  final int? statusCode;

  const ServerException({
    required String message,
    this.statusCode,
    Object? error,
    StackTrace? stackTrace,
  }) : super(message, error: error, stackTrace: stackTrace);

  @override
  List<Object?> get props => [...super.props, statusCode];
}

class NetworkException extends DataException {
  const NetworkException({
    String message = 'Şəbəkə bağlantısı yoxdur.',
    Object? error,
    StackTrace? stackTrace,
  }) : super(message, error: error, stackTrace: stackTrace);
}

class FileLoadException extends DataException {
  const FileLoadException({
    String message = 'Fayl yüklənərkən xəta baş verdi.',
    Object? error,
    StackTrace? stackTrace,
  }) : super(message, error: error, stackTrace: stackTrace);
}

class InvalidJsonException extends DataException {
  const InvalidJsonException({
    String message = 'Format uyğunsuzluğu (JSON parsing).',
    Object? error,
    StackTrace? stackTrace,
  }) : super(message, error: error, stackTrace: stackTrace);
}
