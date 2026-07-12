import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:keuangan_app/core/api_client.dart';
import 'package:keuangan_app/core/api_exception.dart';

class _FakeTokenProvider {
  String? token;
  Future<String?> call() async => token;
}

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late _FakeTokenProvider tokenProvider;
  late ApiClient client;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    adapter = DioAdapter(dio: dio);
    tokenProvider = _FakeTokenProvider()..token = 'tok123';
    client = ApiClient(dio: dio, getToken: tokenProvider.call);
  });

  test('GET decodes JSON body', () async {
    adapter.onGet('/dashboard', (s) => s.reply(200, {'balance': 100}));
    final res = await client.getJson('/dashboard');
    expect(res['balance'], 100);
  });

  test('attaches bearer token from provider', () async {
    adapter.onGet('/categories', (s) => s.reply(200, []),
        headers: {'Authorization': 'Bearer tok123'});
    final res = await client.getJsonList('/categories');
    expect(res, isEmpty);
  });

  test('maps error body to ApiException', () async {
    adapter.onPost(
        '/families/join',
        (s) => s.reply(404, {
              'error': {'code': 'NOT_FOUND', 'message': 'kode tidak ditemukan'}
            }),
        data: {'code': 'ZZZ'});
    expect(
      () => client.postJson('/families/join', {'code': 'ZZZ'}),
      throwsA(isA<ApiException>()
          .having((e) => e.status, 'status', 404)
          .having((e) => e.code, 'code', 'NOT_FOUND')),
    );
  });
}
