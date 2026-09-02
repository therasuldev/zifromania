import 'package:zifromania/core/errors/app_exception.dart';

sealed class DomainException extends AppException {
  const DomainException(super.message, {super.error, super.stackTrace});
}

class DailyLimitReachedException extends DomainException {
  const DailyLimitReachedException({
    String message = 'Günlük limitə çatdınız.',
    Object? error,
    StackTrace? stackTrace,
  }) : super(message, error: error, stackTrace: stackTrace);
}

class InsufficientCoinsException extends DomainException {
  final int? requiredCoins;
  final int? currentCoins;

  const InsufficientCoinsException({
    this.requiredCoins,
    this.currentCoins,
    String message = 'Kifayət qədər balans yoxdur.',
    Object? error,
    StackTrace? stackTrace,
  }) : super(message, error: error, stackTrace: stackTrace);

  @override
  List<Object?> get props => [...super.props, requiredCoins, currentCoins];
}

class UnknownException extends AppException {
  const UnknownException({
    String message = 'Bilinməyən xəta baş verdi.',
    Object? error,
    StackTrace? stackTrace,
  }) : super(message, error: error, stackTrace: stackTrace);
}
