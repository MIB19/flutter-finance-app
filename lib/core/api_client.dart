import 'package:dio/dio.dart';
import 'api_exception.dart';

typedef TokenProvider = Future<String?> Function();

class ApiClient {
  final Dio _dio;
  final TokenProvider _getToken;

  ApiClient({required Dio dio, required TokenProvider getToken})
      : _dio = dio,
        _getToken = getToken {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      final token = await _getToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    }));
  }

  Future<Map<String, dynamic>> getJson(String path) async =>
      _unwrap(await _guard(() => _dio.get(path))) as Map<String, dynamic>;

  Future<List<dynamic>> getJsonList(String path) async =>
      _unwrap(await _guard(() => _dio.get(path))) as List<dynamic>;

  Future<Map<String, dynamic>> postJson(String path, Object body) async =>
      _unwrap(await _guard(() => _dio.post(path, data: body))) as Map<String, dynamic>;

  Future<Map<String, dynamic>> patchJson(String path, Object body) async =>
      _unwrap(await _guard(() => _dio.patch(path, data: body))) as Map<String, dynamic>;

  Future<void> delete(String path) async {
    await _guard(() => _dio.delete(path));
  }

  dynamic _unwrap(Response res) => res.data;

  Future<Response> _guard(Future<Response> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] is Map) {
        final err = data['error'] as Map;
        throw ApiException(e.response?.statusCode ?? 0, err['code']?.toString() ?? 'ERROR', err['message']?.toString() ?? 'error');
      }
      throw ApiException(e.response?.statusCode ?? 0, 'NETWORK', e.message ?? 'network error');
    }
  }
}
