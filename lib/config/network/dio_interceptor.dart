import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rudra/config/utils/local_storage.dart';

/// Interceptor to handle token refresh and authentication errors
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  static bool _isRefreshing = false;
  static Future<bool>? _refreshFuture;

  AuthInterceptor(this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenHandler.getString("token");

    if (token.isNotEmpty) {
      String finalToken = token;
      if (_isTokenExpired(token)) {
        bool refreshed = false;
        if (!_isRefreshing) {
          _isRefreshing = true;
          _refreshFuture = _refreshToken();
          refreshed = await _refreshFuture!;
          _isRefreshing = false;
        } else if (_refreshFuture != null) {
          refreshed = await _refreshFuture!;
        }
        if (refreshed) {
          finalToken = await TokenHandler.getString("token");
        }
      }
      options.headers['Authorization'] = 'Bearer ${finalToken.trim()}';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (err.requestOptions.path != '/auth/refresh-token') {
        bool refreshed = false;
        if (!_isRefreshing) {
          _isRefreshing = true;
          _refreshFuture = _refreshToken();
          refreshed = await _refreshFuture!;
          _isRefreshing = false;
        } else if (_refreshFuture != null) {
          refreshed = await _refreshFuture!;
        }

        if (refreshed) {
          final newToken = await TokenHandler.getString("token");
          err.requestOptions.headers['Authorization'] = 'Bearer ${newToken.trim()}';
          
          // DO NOT retry requests with FormData - they will fail as the stream is already consumed
          if (err.requestOptions.data is FormData) {
            return handler.next(err);
          }

          try {
            final response = await _dio.fetch(err.requestOptions);
            return handler.resolve(response);
          } catch (_) {}
        }
      }

      await TokenHandler.remove("token");
      await TokenHandler.remove("refresh_token");
      await TokenHandler.remove("user");
    }

    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      if (err.message?.contains('Connection reset by peer') ?? false) {
        try {
          final response = await _retry(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {}
      }
    }

    handler.next(err);
  }

  /// Check if JWT token is expired (or expiring within 5 minutes)
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      if (payloadMap['exp'] != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(
          payloadMap['exp'] * 1000,
        );
        return expiryDate.isBefore(DateTime.now().add(const Duration(minutes: 5)));
      }
    } catch (e) {
      debugPrint("❌ [AUTH] Error checking token expiry: $e");
      return true;
    }
    return false;
  }

  /// API call to refresh token using a separate Dio instance (avoids interceptor loop)
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await TokenHandler.getString("refresh_token");
      if (refreshToken.isEmpty) return false;

      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final response = await refreshDio.post(
        "/auth/refresh-token",
        data: {
          "refreshToken": refreshToken,
          "refresh_token": refreshToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          final newToken = data['data']['token'];
          final newRefreshToken = data['data']['refreshToken'] ??
              data['data']['refresh_token'] ??
              refreshToken;
          if (newToken != null) {
            await TokenHandler.setString("token", newToken);
            await TokenHandler.setString("refresh_token", newRefreshToken);
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint("❌ [AUTH] Token refresh failed: $e");
      return false;
    }
  }

  /// Retry a failed request after a short delay
  Future<Response> _retry(RequestOptions requestOptions) async {
    await Future.delayed(const Duration(seconds: 2));
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}

/// Interceptor to handle network retry with exponential backoff
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;

  RetryInterceptor(this._dio, {this.maxRetries = 3});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown ||
        err.type == DioExceptionType.connectionTimeout) {
      final retryCount = err.requestOptions.extra['retry_count'] ?? 0;

      // DO NOT retry POST/PATCH requests with FormData - FormData stream cannot be reused easily
      if ((err.requestOptions.method == 'POST' || err.requestOptions.method == 'PATCH') && 
          err.requestOptions.data is FormData) {
        handler.next(err);
        return;
      }

      if (retryCount < maxRetries) {
        // Exponential backoff: 1s, 2s, 4s
        final delay = Duration(seconds: (1 << retryCount));
        await Future.delayed(delay);

        err.requestOptions.extra['retry_count'] = retryCount + 1;

        try {
          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {}
      }
    }

    handler.next(err);
  }
}
