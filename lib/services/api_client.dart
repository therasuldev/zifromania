import 'package:dio/dio.dart';
import 'firebase_auth_service.dart';

class ApiClient {
  final Dio dio;
  final FirebaseAuthService firebaseAuthService;

  ApiClient({
    required this.dio,
    required this.firebaseAuthService,
  }) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: _onError,
      ),
    );
  }

  Future<void> _onError(
    DioException exception,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = exception.response?.statusCode;
    // final responseData = exception.response?.data;

    if (statusCode == 401) {
      await _handleTokenRefresh(exception, handler);
      return;
    }

    handler.next(exception);
  }

  Future<void> _handleTokenRefresh(
    DioException exception,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final newToken = await firebaseAuthService.getServiceAccountToken();

      final clonedRequest = await dio.request(
        exception.requestOptions.path,
        options: Options(
          method: exception.requestOptions.method,
          headers: {
            ...exception.requestOptions.headers,
            'Authorization': 'Bearer $newToken',
          },
        ),
        data: exception.requestOptions.data,
        queryParameters: exception.requestOptions.queryParameters,
      );

      handler.resolve(clonedRequest);
    } catch (_) {
      handler.reject(exception);
    }
  }
}
