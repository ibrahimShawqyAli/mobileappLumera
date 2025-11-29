import 'package:dio/dio.dart';
import 'package:smart_home_iotz/shared/variables/variables.dart';

class DioHelper {
  static late Dio _dio;

  /// Call this once in main()
  static void init({
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseURL,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        responseType: ResponseType.json,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Attach token + merge per-call headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final needsAuth = (options.extra['auth'] as bool?) ?? true;

          // Use your existing global "token" as-is
          if (needsAuth && token != null && token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Merge caller-provided headers if any
          final extraHeaders =
              options.extra['headers'] as Map<String, dynamic>?;
          if (extraHeaders != null) {
            options.headers.addAll(extraHeaders);
          }

          handler.next(options);
        },
      ),
    );
  }

  /// ---------- Generic helpers (accept query/body/headers/etc.) ----------

  /// GET
  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool auth = true,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ResponseType? responseType, // e.g. ResponseType.bytes for downloads
    String? contentType,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      options: Options(
        extra: {'auth': auth, 'headers': headers},
        responseType: responseType,
        contentType: contentType,
      ),
    );
  }

  /// POST
  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool auth = true,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    ResponseType? responseType,
    String? contentType, // 'application/json', 'multipart/form-data', etc.
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      options: Options(
        extra: {'auth': auth, 'headers': headers},
        responseType: responseType,
        contentType: contentType,
      ),
    );
  }

  /// PUT
  static Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool auth = true,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    ResponseType? responseType,
    String? contentType,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      options: Options(
        extra: {'auth': auth, 'headers': headers},
        responseType: responseType,
        contentType: contentType,
      ),
    );
  }

  /// DELETE (supports body for APIs that accept it)
  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool auth = true,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    ResponseType? responseType,
    String? contentType,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      // Dio doesn't forward progress in delete() by default, but keep for parity
      options: Options(
        extra: {'auth': auth, 'headers': headers},
        responseType: responseType,
        contentType: contentType,
      ),
    );
  }
}
