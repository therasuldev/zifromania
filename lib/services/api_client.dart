import 'package:dio/dio.dart';
import 'access_token_service.dart';

class ApiClient {
  final Dio dio;
  final AccessTokenService tokenService;

  ApiClient({
    required this.dio,
    required this.tokenService,
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
      final newToken = await tokenService.getAccessToken();

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
