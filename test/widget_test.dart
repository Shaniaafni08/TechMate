import 'package:flutter_test/flutter_test.dart';

import 'package:project_pertama/main.dart';

void main() {
  testWidgets('TechMate berhasil dijalankan', (WidgetTester tester) async {
    await tester.pumpWidget(const TechMateApp());

    expect(find.text('TechMate'), findsOneWidget);
  });
}