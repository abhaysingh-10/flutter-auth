import 'package:dio/dio.dart';
import '../storage/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storage = StorageService();
  final Dio _dio;

  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Don't add token for login and register requests
    if (options.path.contains('login') || options.path.contains('register')) {
      return handler.next(options);
    }

    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        try {
          // Attempt to refresh token
          final response = await _dio.post('auth/refresh/', data: {
            'refresh': refreshToken,
          });

          final newAccess = response.data['access'];
          final newRefresh = response.data['refresh'];

          await _storage.saveTokens(access: newAccess, refresh: newRefresh);

          // Retry the original request with new token
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
          final cloneReq = await _dio.fetch(err.requestOptions);
          return handler.resolve(cloneReq);
        } catch (e) {
          // Refresh failed, logout user
          await _storage.clearTokens();
        }
      }
    }
    return handler.next(err);
  }
}
