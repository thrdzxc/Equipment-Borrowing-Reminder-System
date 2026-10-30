
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:equipment_borrowing_reminder_system/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Equipment Borrowing login screen loads', (tester) async {
    // Use a desktop-sized viewport.
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const BorrowingApp());

    // Allow the initial interface to render.
    await tester.pump();

    // Verify the two login inputs.
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Verify the login button.
    expect(find.text('Sign in'), findsWidgets);

    // Verify the branding.
    expect(
      find.textContaining('Equipment Borrowing'),
      findsWidgets,
    );
  });
}
