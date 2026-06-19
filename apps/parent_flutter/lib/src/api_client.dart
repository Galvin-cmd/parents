import 'dart:convert';
import 'dart:io';

import 'app_state.dart';

class ApiClient {
  ApiClient({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  String get _baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1';
    return 'http://127.0.0.1:8000/api/v1';
  }

  Future<BootstrapData> bootstrap() async {
    final uri = Uri.parse('$_baseUrl/bootstrap');
    final request = await _httpClient
        .getUrl(uri)
        .timeout(const Duration(seconds: 3));
    final response = await request.close().timeout(const Duration(seconds: 5));
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException('接口暂时不可用');
    }

    final payload = jsonDecode(body) as Map<String, dynamic>;
    if (payload['code'] != 0) {
      throw ApiException(payload['message']?.toString() ?? '接口返回异常');
    }

    return BootstrapData.fromJson(
      payload['data'] as Map<String, dynamic>? ?? {},
    );
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
