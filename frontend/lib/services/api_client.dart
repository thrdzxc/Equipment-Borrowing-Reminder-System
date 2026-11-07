import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int status;
  const ApiException(this.message, this.status);
  @override
  String toString() => message;
}

/// Bearer token lives only in memory. Do NOT write it to localStorage,
/// SharedPreferences, URLs, logs or compiled Dart defines.
class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL', defaultValue: 'http://127.0.0.1:8000/api');

  final http.Client client;
  String? token;
  String? role;
  void Function()? onUnauthorized;

  ApiClient({http.Client? client}) : client = client ?? http.Client();

  bool get canManageInventory => role == 'custodian';
  bool get canManageBorrowings => role == 'custodian' || role == 'staff';
  bool get canManageAutomation => role == 'custodian';

  Future<dynamic> call(String method, String path, [Map<String, dynamic>? data]) async {
    final uri = Uri.parse('$baseUrl$path');
    // Never allow an HTTPS Flutter page to submit a bearer token over plaintext.
    // HTTP is permitted ONLY for the localhost development demonstration.
    if (Uri.base.scheme == 'https' && uri.scheme != 'https') {
      throw const ApiException('Secure page requires an HTTPS API endpoint.', 0);
    }
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    http.Response response;
    try {
      if (method == 'POST') {
        response = await client.post(uri, headers: headers,
          body: jsonEncode(data ?? {})).timeout(const Duration(seconds: 10));
      } else if (method == 'GET') {
        response = await client.get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));
      } else {
        throw const ApiException('Unsupported API method.', 0);
      }
    } on ApiException {
      rethrow;
    } catch (_) {
      // Never expose exception payloads or bearer tokens in UI errors.
      throw const ApiException('Cannot reach the Laravel API. Check the server, URL and CORS settings.', 0);
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = <String, dynamic>{};
    }
    if (response.statusCode >= 400) {
      if (response.statusCode == 401 && token != null) {
        token = null;
        role = null;
        onUnauthorized?.call();
      }
      var message = decoded is Map
          ? '${decoded['message'] ?? 'API request failed'}'
          : 'API request failed';
      if (decoded is Map && decoded['errors'] is Map &&
          (decoded['errors'] as Map).isNotEmpty) {
        final first = (decoded['errors'] as Map).values.first;
        if (first is List && first.isNotEmpty) message = '${first.first}';
      }
      throw ApiException(message, response.statusCode);
    }
    return decoded;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = Map<String, dynamic>.from(
        await call('POST', '/auth/login', {'email': email, 'password': password}));
    final issuedToken = result['token'];
    final user = result['user'];
    if (issuedToken is! String || issuedToken.isEmpty || user is! Map ||
        !['custodian', 'staff', 'student'].contains(user['role'])) {
      throw const ApiException('Unexpected login response.', 0);
    }
    token = issuedToken;
    role = user['role'] as String;
    return result;
  }

  Future<void> logout() async {
    try {
      if (token != null) await call('POST', '/auth/logout');
    } finally {
      token = null;
      role = null;
    }
  }
}
