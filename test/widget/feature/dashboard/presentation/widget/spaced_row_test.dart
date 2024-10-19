import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/feature/dashboard/presentation/widget/spaced_row.dart';

void main() {
  [
    0.0, // zero
    1.0, // value other than default value
    null, // default value
  ].forEach((expectedWidth) {
    testWidgets('space is ${expectedWidth ?? 'default value'} between children',
        (tester) async {
      const children = [
        Text('1'),
        Text('2'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: expectedWidth == null
              ? const SpacedRow(children: children)
              : SpacedRow(
                  spaceWidth: expectedWidth,
                  children: children,
                ),
        ),
      );

      final child1TopRightX = tester.getTopRight(find.text('1')).dx;
      final child2TopLeftX = tester.getTopLeft(find.text('2')).dx;
      final actualSpace = child2TopLeftX - child1TopRightX;

      expect(actualSpace, equals(expectedWidth ?? SpacedRow.defaultWidth));
    });
  });

  testWidgets('spaceRow must be greater than or equal to 0', (tester) async {
    expect(
        () => SpacedRow(
              spaceWidth: -1.0,
              children: const [],
            ),
        throwsAssertionError);
  });
}
