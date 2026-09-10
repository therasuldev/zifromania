import 'package:zifromania/core/errors/app_exception.dart';

class GoogleSignInCancelledException extends AppException {
  const GoogleSignInCancelledException({
    String message = 'Google ilə daxil olma ləğv edildi.',
    Object? error,
    StackTrace? stackTrace,
  }) : super(message, error: error, stackTrace: stackTrace);
}