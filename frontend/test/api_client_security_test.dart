import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:equipment_borrowing_reminder_system/services/api_client.dart';

void main() {
  test('login captures server-assigned role and keeps token in memory', () async {
    final mock = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, endsWith('/auth/login'));
      expect(request.headers.containsKey('Authorization'), false);
      return http.Response(jsonEncode({
        'token': 'fictional-session-token',
        'user': {'name': 'Fictional Custodian', 'role': 'custodian'},
        'expires_in_minutes': 60,
      }), 200);
    });
    final api = ApiClient(client: mock);
    final response = await api.login('custodian@example.test', 'local-test-only-password');
    expect(response['user']['role'], 'custodian');
    expect(api.canManageInventory, true);
    expect(api.canManageAutomation, true);
    expect(api.token, 'fictional-session-token');
    api.client.close();
  });

  test('401 clears in-memory bearer and notifies the application', () async {
    final mock = MockClient((request) async {
      expect(request.headers['Authorization'], 'Bearer fictional-session-token');
      return http.Response(jsonEncode({'message': 'Unauthenticated.'}), 401);
    });
    final api = ApiClient(client: mock)
      ..token = 'fictional-session-token'
      ..role = 'staff';
    var notified = false;
    api.onUnauthorized = () => notified = true;
    await expectLater(api.call('GET', '/equipment'), throwsA(isA<ApiException>()));
    expect(api.token, isNull);
    expect(api.role, isNull);
    expect(notified, true);
    api.client.close();
  });

  test('403 does not escalate role or leak sensitive values in error', () async {
    final mock = MockClient((request) async =>
        http.Response(jsonEncode({'message': 'Access denied for this account role.'}), 403));
    final api = ApiClient(client: mock)
      ..token = 'fictional-session-token'
      ..role = 'student';
    await expectLater(
      api.call('GET', '/borrowings'),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 403)),
    );
    expect(api.role, 'student');
    expect(api.canManageBorrowings, false);
    api.client.close();
  });
}
