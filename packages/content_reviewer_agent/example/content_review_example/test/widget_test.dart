// Basic widget test for content review example app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:content_review_example/main.dart';

void main() {
  testWidgets('App loads and shows content review screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text('Content Reviewer Agent'), findsOneWidget);

    // Verify that main UI elements are present
    expect(find.text('Content to Review'), findsOneWidget);
    expect(find.text('API Base URL'), findsOneWidget);
  });
}
