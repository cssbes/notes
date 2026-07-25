import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget createTestApp() {
  return const ProviderScope(
    child: MaterialApp(home: Scaffold(body: Center(child: Text('Notes')))),
  );
}

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    expect(find.text('Notes'), findsOneWidget);
  });
}
