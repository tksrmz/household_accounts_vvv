import 'package:flutter/material.dart';

class GoldenWrapper extends StatelessWidget {
  const GoldenWrapper({
    required this.child,
    this.fontFamily = 'NotoSansJP',
    super.key,
  });

  final String fontFamily;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: fontFamily,
      ),
      home: Scaffold(
        body: RepaintBoundary(
          child: child,
        ),
      ),
    );
  }
}
