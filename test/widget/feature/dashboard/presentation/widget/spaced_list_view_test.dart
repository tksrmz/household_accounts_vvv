import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/feature/dashboard/presentation/widget/spaced_list_view.dart';

void main() {
  [
    0.0, // zero
    1.0, // value other than default value
    null, // default value
  ].forEach((expectedHeight) {
    testWidgets(
        'space is ${expectedHeight ?? 'default value'} between children',
        (tester) async {
      const children = [
        Text('Child 1'),
        Text('Child 2'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: expectedHeight == null
              ? const SpacedListView(children: children)
              : SpacedListView(
                  spaceHeight: expectedHeight,
                  children: children,
                ),
        ),
      );

      final child1BottomLeftY = tester.getBottomLeft(find.text('Child 1')).dy;
      final child2TopLeftY = tester.getTopLeft(find.text('Child 2')).dy;
      final actualSpace = child2TopLeftY - child1BottomLeftY;

      expect(
        actualSpace,
        equals(expectedHeight ?? SpacedListView.defaultHeight),
      );
    });
  });

  testWidgets('spaceHeight must be greater than or equal to 0', (tester) async {
    expect(
        () => SpacedListView(
              spaceHeight: -1.0,
              children: const [],
            ),
        throwsAssertionError);
  });
}
