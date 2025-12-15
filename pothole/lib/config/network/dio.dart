import 'package:dio/dio.dart';
import 'package:pothole/config/utils/local_storage.dart';

Future<Dio> createBaseDio() async {
  final String baseUrl = "https://pwd.mockify.org/api/v1";
  final BaseOptions baseOptions = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(milliseconds: 30000),
    receiveTimeout: const Duration(milliseconds: 30000),
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
        baseUrl: "https://pwd.mockify.org/api/v1",
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
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
        'Accept': '*/*',
        "Authorization": "Bearer $token",
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
        "Authorization": "Bearer $token",
      },
    );
  }
}
