
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:equipment_borrowing_reminder_system/main.dart';

void main() {
  testWidgets('Login fields and submit button are available',
          (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const BorrowingApp());
        await tester.pump();

        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.text('Sign in'), findsWidgets);
      });
}
