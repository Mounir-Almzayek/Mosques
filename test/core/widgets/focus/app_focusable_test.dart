import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/widgets/focus/app_focusable.dart';

void main() {
  testWidgets('AppFocusable fires onPressed on pointer tap', (tester) async {
    var count = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppFocusable(
          onPressed: () => count++,
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    ));
    await tester.tap(find.byType(AppFocusable));
    expect(count, 1);
  });

  testWidgets('AppFocusable fires onPressed on Enter key when focused', (tester) async {
    var count = 0;
    final node = FocusNode();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppFocusable(
          focusNode: node,
          onPressed: () => count++,
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    ));
    node.requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(count, 1);
    node.dispose();
  });

  testWidgets('AppFocusable disabled blocks tap', (tester) async {
    var count = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppFocusable(
          enabled: false,
          onPressed: () => count++,
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    ));
    await tester.tap(find.byType(AppFocusable));
    expect(count, 0);
  });
}
