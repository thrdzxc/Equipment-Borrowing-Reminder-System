import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:equipment_borrowing_reminder_system/services/api_client.dart';

void main() {
  test('W15-F01: backend 500 details are not leaked to Flutter UI', () async {
    final client = MockClient((_) async => http.Response(
      jsonEncode({'message': 'SQL exception: private internal stack trace'}), 500));
    final api = ApiClient(client: client);
    try {
      await api.call('GET', '/equipment');
      fail('Expected an API exception');
    } on ApiException catch (error) {
      expect(error.status, 500);
      expect(error.message, contains('server encountered a problem'));
      expect(error.message, isNot(contains('SQL')));
      expect(error.message, isNot(contains('stack trace')));
    } finally { client.close(); }
  });

  test('W15-F02: malformed error body is safely handled', () async {
    final client = MockClient((_) async => http.Response('<html>fail</html>', 502));
    final api = ApiClient(client: client);
    await expectLater(api.call('GET', '/equipment'),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 502)));
    client.close();
  });

  test('W15-F03: network exception becomes a safe connection error', () async {
    final client = MockClient((_) async => throw Exception('private upstream details'));
    final api = ApiClient(client: client);
    try {
      await api.call('GET', '/equipment');
      fail('Expected an API exception');
    } on ApiException catch (error) {
      expect(error.status, 0);
      expect(error.message, contains('Cannot reach'));
      expect(error.message, isNot(contains('private upstream details')));
    } finally { client.close(); }
  });

  test('W15-F04: validation response preserves useful error for users', () async {
    final client = MockClient((_) async => http.Response(jsonEncode({
      'message': 'Validation failed',
      'errors': {'due_at': ['The due date must be in the future.']}
    }), 422));
    final api = ApiClient(client: client);
    await expectLater(api.call('POST', '/borrowings', {}),
      throwsA(isA<ApiException>()
        .having((e) => e.status, 'status', 422)
        .having((e) => e.message, 'message', contains('future'))));
    client.close();
  });

  test('W15-F05: forbidden response retains role and active session', () async {
    final client = MockClient((_) async => http.Response(
      jsonEncode({'message': 'Access denied for this account role.'}), 403));
    final api = ApiClient(client: client)
      ..token = 'fictional-session-token'
      ..role = 'student';
    await expectLater(api.call('GET', '/borrowings'),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 403)));
    expect(api.role, 'student');
    expect(api.token, isNotNull);
    client.close();
  });
}
