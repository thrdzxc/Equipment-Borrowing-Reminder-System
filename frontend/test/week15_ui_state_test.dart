import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:equipment_borrowing_reminder_system/main.dart';

Widget shell(Future<dynamic> Function() loader,
    {int refreshKey = 0, Widget Function(dynamic)? builder}) {
  return MaterialApp(
    home: Scaffold(
      body: ApiData(
        loader: loader,
        refreshKey: refreshKey,
        builder: builder ?? (data) => Text('Loaded: $data'),
      ),
    ),
  );
}

void main() {
  testWidgets('W15-UI01: loading state shows progress indicator', (tester) async {
    final pending = Completer<dynamic>();
    await tester.pumpWidget(shell(() => pending.future));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('W15-UI02: unavailable backend displays safe error state', (tester) async {
    await tester.pumpWidget(shell(() => Future<dynamic>.error(
      Exception('Controlled offline demo'))));
    await tester.pumpAndSettle();
    expect(find.textContaining('Check the Laravel API'), findsOneWidget);
  });

  testWidgets('W15-UI03: empty response can render empty message', (tester) async {
    await tester.pumpWidget(shell(() async => <dynamic>[],
      builder: (data) => Text((data as List).isEmpty ? 'No records' : 'Records')));
    await tester.pumpAndSettle();
    expect(find.text('No records'), findsOneWidget);
  });

  testWidgets('W15-UI04: success response renders data', (tester) async {
    await tester.pumpWidget(shell(() async => 'ready'));
    await tester.pumpAndSettle();
    expect(find.text('Loaded: ready'), findsOneWidget);
  });
}
