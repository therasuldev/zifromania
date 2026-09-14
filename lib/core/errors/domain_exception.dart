import 'package:easy_localization/easy_localization.dart';
import 'package:zifromania/core/errors/app_exception.dart';

sealed class DomainException extends AppException {
  const DomainException(super.message, {super.error, super.stackTrace});
}

class DailyLimitReachedException extends DomainException {
  DailyLimitReachedException({
    String? message,
    super.error,
    super.stackTrace,
  }) : super(message ?? 'error.daily_limit_reached'.tr());
}

class InsufficientCoinsException extends DomainException {
  final int? requiredCoins;
  final int? currentCoins;

  InsufficientCoinsException({
    String? message,
    this.requiredCoins,
    this.currentCoins,
    super.error,
    super.stackTrace,
  }) : super(message ?? 'coin.notEnoughCoins'.tr());

  @override
  List<Object?> get props => [...super.props, requiredCoins, currentCoins];
}

class UnknownException extends AppException {
  UnknownException({
    String? message,
    super.error,
    super.stackTrace,
  }) : super(message ?? 'error.unknown'.tr());
}
