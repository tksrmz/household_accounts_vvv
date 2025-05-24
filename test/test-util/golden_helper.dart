import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void testGoldens(
  String description, {
  required String goldenFileName,
  void Function()? mockFn,
  required Widget Function() builder,
  FutureOr<void> Function(WidgetTester)? expectFn,
  bool skip = false,
}) {
  _GoldenTestWidth.values.forEach((width) {
    testWidgets(
      '[golden] ${description} (width: ${width.value})',
      (tester) async {
        // Setup mocks before building the widget
        mockFn?.call();

        final widget = builder();
        await tester.pumpWidget(
          _GoldenWrapper(
            child: widget,
            width: width,
          ),
        );

        // Additional expectations after the widget is built
        await expectFn?.call(tester);

        await expectLater(
          find.byType(widget.runtimeType),
          matchesGoldenFile('golden/${goldenFileName}_${width.value}.png'),
        );
      },
      tags: ['golden'],
      skip: skip,
    );
  });
}

class _GoldenWrapper extends StatelessWidget {
  const _GoldenWrapper({
    required this.child,
    this.width = _GoldenTestWidth.small,
  });

  final Widget child;
  final _GoldenTestWidth width;

  @override
  Widget build(BuildContext context) {
    return GoldenPageWrapper(
      child: Scaffold(
        body: RepaintBoundary(
          child: SizedBox(
            width: width.value,
            child: Container(
              color: const Color(0xFFFFFFFF),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GoldenPageWrapper extends StatelessWidget {
  const GoldenPageWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'NotoSansJP',
      ),
      home: child,
    );
  }
}

enum _GoldenTestWidth {
  /// small size display
  small,

  /// medium size display
  medium,

  /// large size display
  large,
}

extension _GoldenTestWidthExtension on _GoldenTestWidth {
  double get value {
    switch (this) {
      case _GoldenTestWidth.small:
        return 320.0;
      case _GoldenTestWidth.medium:
        return 375.0;
      case _GoldenTestWidth.large:
        return 414.0;
    }
  }
}
