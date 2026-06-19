import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'app_state.dart';

class ApiClient {
  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  String get _baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  Future<BootstrapData> bootstrap() async {
    final data = await _request('GET', '/bootstrap');
    return BootstrapData.fromJson(data);
  }

  Future<void> bindDevice(String childId, String bindCode) async {
    await _request(
      'POST',
      '/devices/bind',
      body: {'childId': childId, 'bindCode': bindCode},
    );
  }

  Future<TaskItem> createTask(
    String childId,
    String title,
    String time,
    int reward,
  ) async {
    final data = await _request(
      'POST',
      '/children/$childId/tasks',
      body: {'title': title, 'time': time, 'reward': reward},
    );
    return TaskItem.fromJson(data);
  }

  Future<void> updateTask(String taskId, bool done) async {
    await _request('PATCH', '/tasks/$taskId', body: {'done': done});
  }

  Future<void> updateZone(String zoneId, bool enabled) async {
    await _request('PATCH', '/geo-zones/$zoneId', body: {'enabled': enabled});
  }

  Future<void> updateMode(String childId, String modeId, bool enabled) async {
    await _request(
      'PATCH',
      '/children/$childId/control/modes/$modeId',
      body: {'enabled': enabled},
    );
  }

  Future<void> updateApp(String childId, String appId, bool enabled) async {
    await _request(
      'PATCH',
      '/children/$childId/apps/$appId',
      body: {'enabled': enabled},
    );
  }

  Future<ContactItem> createContact(
    String childId,
    String name,
    String relation,
    String phone,
  ) async {
    final data = await _request(
      'POST',
      '/children/$childId/contacts',
      body: {
        'name': name,
        'relation': relation,
        'phone': phone,
        'trusted': true,
      },
    );
    return ContactItem.fromJson(data);
  }

  Future<String> sendAgentMessage(String childId, String text) async {
    final data = await _request(
      'POST',
      '/children/$childId/agent/messages',
      body: {'text': text},
    );
    return data['reply']?.toString() ?? '已处理';
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = {'Content-Type': 'application/json'};
    final encodedBody = body == null ? null : jsonEncode(body);
    late http.Response response;

    switch (method) {
      case 'GET':
        response = await _httpClient
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 4));
      case 'POST':
        response = await _httpClient
            .post(uri, headers: headers, body: encodedBody)
            .timeout(const Duration(seconds: 4));
      case 'PATCH':
        response = await _httpClient
            .patch(uri, headers: headers, body: encodedBody)
            .timeout(const Duration(seconds: 4));
      default:
        throw ApiException('不支持的请求方法');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('接口暂时不可用：${response.statusCode}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    if (payload['code'] != 0) {
      throw ApiException(payload['message']?.toString() ?? '接口返回异常');
    }

    return payload['data'] as Map<String, dynamic>? ?? {};
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
