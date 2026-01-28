import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rudra/config/utils/local_storage.dart';
import 'package:rudra/config/constants/api_constants.dart';

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
  dio.interceptors.addAll([LogInterceptor(responseBody: true)]);

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
    _dioClient.interceptors.addAll([LogInterceptor(responseBody: true)]);
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
    debugPrint("🌐 [iOS DEBUG] patch called");
    debugPrint("🌐 [iOS DEBUG] URL: $url");
    debugPrint("🌐 [iOS DEBUG] Data: $data");
    debugPrint("🌐 [iOS DEBUG] Query parameters: $queryParameters");
    
    final options = await _getRequestOptions();
    debugPrint("🌐 [iOS DEBUG] Request headers: ${options.headers}");
    
    try {
      final response = await _dioClient.patch(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      debugPrint("🌐 [iOS DEBUG] patch response received");
      debugPrint("🌐 [iOS DEBUG] Response status: ${response.statusCode}");
      
      return response;
    } catch (e) {
      debugPrint("❌ [iOS DEBUG] patch error: $e");
      rethrow;
    }
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
    debugPrint("🌐 [iOS DEBUG] patchMultipart called");
    debugPrint("🌐 [iOS DEBUG] URL: $url");
    debugPrint("🌐 [iOS DEBUG] Query parameters: $queryParameters");
    
    final token = await TokenHandler.getString("token");
    debugPrint("🌐 [iOS DEBUG] Token retrieved successfully");

    final options = Options(
      headers: {
        'Accept': 'application/json',
        "Authorization": "Bearer ${token.trim()}",
        // DO NOT set Content-Type here — Dio sets it automatically for multipart/form-data
      },
    );
    
    debugPrint("🌐 [iOS DEBUG] Request headers: ${options.headers}");
    debugPrint("🌐 [iOS DEBUG] FormData fields: ${formData.fields}");
    debugPrint("🌐 [iOS DEBUG] FormData files count: ${formData.files.length}");

    try {
      final response = await _dioClient.patch(
        url,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: (sent, total) {
          debugPrint("🌐 [iOS DEBUG] Upload progress: $sent / $total bytes");
          onSendProgress?.call(sent, total);
        },
        onReceiveProgress: onReceiveProgress,
      );
      
      debugPrint("🌐 [iOS DEBUG] patchMultipart response received");
      debugPrint("🌐 [iOS DEBUG] Response status: ${response.statusCode}");
      
      return response;
    } catch (e) {
      debugPrint("❌ [iOS DEBUG] patchMultipart error: $e");
      rethrow;
    }
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
