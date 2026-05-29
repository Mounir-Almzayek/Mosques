import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/widgets/focus/focus_ring.dart';

void main() {
  testWidgets('FocusRing paints a highlight border when focused', (tester) async {
    final node = FocusNode();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FocusRing(
          focusNode: node,
          borderRadius: BorderRadius.circular(8),
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    ));

    expect(find.byKey(const ValueKey('focus_ring_highlight')), findsNothing);

    node.requestFocus();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('focus_ring_highlight')), findsOneWidget);

    node.dispose();
  });
}
