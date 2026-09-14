import 'package:easy_localization/easy_localization.dart';
import 'package:zifromania/core/errors/app_exception.dart';

class GoogleSignInCancelledException extends AppException {
  GoogleSignInCancelledException({
    String? message,
    super.error,
    super.stackTrace,
  }) : super(message ?? 'error.google_sign_in_cancelled'.tr());
}

class FirebaseUserNotFoundException extends AppException {
  FirebaseUserNotFoundException({
    String? message,
    super.error,
    super.stackTrace,
  }) : super(message ?? 'error.firebase_user_not_found'.tr());
}
