import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rudra/config/utils/local_storage.dart';
import 'package:rudra/config/constants/api_constants.dart';
import 'package:rudra/config/network/dio_interceptor.dart';

Future<Dio> createBaseDio() async {
  final String baseUrl = ApiConstants.baseUrl;
  final BaseOptions baseOptions = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(
      seconds: 60,
    ), // Increased for large file uploads
    receiveTimeout: const Duration(
      seconds: 120,
    ), // 2 minutes for image processing
  );

  final Dio dio = Dio(baseOptions);
  
  dio.interceptors.addAll([
    AuthInterceptor(dio),
    RetryInterceptor(dio, maxRetries: 3),
  ]);

  return dio;
}

class HTTP {
  late final Dio _dioClient; // Ensuring it's not null

  HTTP() {
    _dioClient = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          seconds: 60,
        ), // Increased for large file uploads
        receiveTimeout: const Duration(
          seconds: 120,
        ), // 2 minutes for image processing
      ),
    );
    
    _dioClient.interceptors.addAll([
      AuthInterceptor(_dioClient),
      RetryInterceptor(_dioClient, maxRetries: 3),
    ]);
  }

  Future<Response> get({
    required String url,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
  }) async {
    final options = await _getRequestOptions();
    return await _dioClient.get(
      url,
      queryParameters: queryParameters,
      options: options,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> delete({
    required String url,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
  }) async {
    final options = await _getRequestOptions();
    return await _dioClient.delete(
      url,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final options = await _getRequestOptions();
    return await _dioClient.post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> patch({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final options = await _getRequestOptions();
    return await _dioClient.patch(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> postMultipart({
    required String url,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final token = await TokenHandler.getString("token");

    final options = Options(
      headers: {
        'Accept': 'application/json',
        "Authorization": "Bearer ${token.trim()}",
        // DO NOT set Content-Type here — Dio sets it automatically for multipart/form-data
      },
    );

    return await _dioClient.post(
      url,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> patchMultipart({
    required String url,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final token = await TokenHandler.getString("token");
    final options = Options(
      headers: {
        'Accept': 'application/json',
        "Authorization": "Bearer ${token.trim()}",
        // DO NOT set Content-Type — Dio sets it automatically for multipart/form-data
      },
    );
    return await _dioClient.patch(
      url,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> put({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final options = await _getRequestOptions();
    return await _dioClient.put(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Options> _getRequestOptions() async {
    final token = await TokenHandler.getString("token");
    return Options(
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "Authorization": "Bearer ${token.trim()}",
      },
    );
  }
}
