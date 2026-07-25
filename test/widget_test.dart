import 'package:flutter_test/flutter_test.dart';
import 'package:dd/app.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const NotesApp());
    expect(find.text('Notes'), findsOneWidget);
  });
}
