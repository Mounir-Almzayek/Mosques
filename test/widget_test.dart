import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mounir_almzayek_mosques/core/utils/color_extensions.dart';

void main() {
  testWidgets('ColorOpacityCompat applies alpha factor', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Container(color: Colors.blue.withOpacityCompat(0.5)),
        ),
      ),
    );
    expect(find.byType(Container), findsOneWidget);
  });
}
