import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/widgets/focus/tv_navigation_scope.dart';

void main() {
  testWidgets('TvNavigationScope invokes onDismiss on Escape', (tester) async {
    var dismissed = 0;
    final node = FocusNode();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TvNavigationScope(
          onDismiss: () => dismissed++,
          child: Focus(focusNode: node, autofocus: true, child: const SizedBox(width: 40, height: 40)),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(dismissed, 1);
    node.dispose();
  });

  testWidgets('TvNavigationScope wraps content in a FocusTraversalGroup', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TvNavigationScope(child: const SizedBox(width: 40, height: 40)),
      ),
    ));
    expect(find.byType(FocusTraversalGroup), findsOneWidget);
  });
}
