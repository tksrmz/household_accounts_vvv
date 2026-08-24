import 'package:flutter/widgets.dart';

class SpacedRow extends StatelessWidget {
  final List<Widget> children;
  final double spaceWidth;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;

  static const double defaultWidth = 10.0;

  const SpacedRow({
    super.key,
    required this.children,
    this.spaceWidth = defaultWidth,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  }) : assert(spaceWidth >= 0, 'spaceWidth must be greater than or equal to 0');

  @override
  Widget build(BuildContext context) {
    List<Widget> rowChildren = [];

    for (int i = 0; i < children.length; i++) {
      rowChildren.add(children[i]);
      if (i < children.length - 1) {
        // Add space after each widget except the last one
        rowChildren.add(SizedBox(width: spaceWidth));
      }
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: rowChildren,
    );
  }
}
