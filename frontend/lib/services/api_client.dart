import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int status;
  const ApiException(this.message, this.status);
  @override
  String toString() => message;
}

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL', defaultValue: 'http://127.0.0.1:8000/api');
  final http.Client client;
  String? token;
  ApiClient({http.Client? client}) : client = client ?? http.Client();

  Future<dynamic> call(String method, String path, [Map<String, dynamic>? data]) async {
    final headers = <String, String>{'Accept': 'application/json', 'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    http.Response r;
    try {
      final uri = Uri.parse('$baseUrl$path');
      if (method == 'POST') {
        r = await client.post(uri, headers: headers, body: jsonEncode(data ?? {})).timeout(const Duration(seconds: 10));
      } else {
        r = await client.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      }
    } catch (_) {
      throw const ApiException('Cannot reach the Laravel API. Check the server, URL and CORS settings.', 0);
    }
    dynamic decoded;
    try { decoded = jsonDecode(r.body); } catch (_) { decoded = <String, dynamic>{}; }
    if (r.statusCode >= 400) {
      var message = decoded is Map ? '${decoded['message'] ?? 'API request failed'}' : 'API request failed';
      if (decoded is Map && decoded['errors'] is Map && (decoded['errors'] as Map).isNotEmpty) {
        final first = (decoded['errors'] as Map).values.first;
        if (first is List && first.isNotEmpty) message = '${first.first}';
      }
      throw ApiException(message, r.statusCode);
    }
    return decoded;
  }
  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = Map<String, dynamic>.from(await call('POST', '/auth/login', {'email': email, 'password': password}));
    token = result['token'] as String?;
    return result;
  }
  Future<void> logout() async {
    try { if (token != null) await call('POST', '/auth/logout'); } finally { token = null; }
  }
}
