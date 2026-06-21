import 'package:flutter/material.dart';

class LoginSplitLayout extends StatelessWidget {
  const LoginSplitLayout({
    super.key,
    required this.brandPanel,
    required this.formPanel,
  });

  final Widget brandPanel;
  final Widget formPanel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 5, child: brandPanel),
        Expanded(flex: 4, child: formPanel),
      ],
    );
  }
}
