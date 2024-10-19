import 'package:flutter/widgets.dart';

class SpacedListView extends StatelessWidget {
  final List<Widget> children;
  final double spaceHeight;
  final EdgeInsetsGeometry? padding;

  static const double defaultHeight = 10.0;

  const SpacedListView({
    super.key,
    required this.children,
    this.spaceHeight = defaultHeight,
    this.padding,
  }) : assert(
          spaceHeight >= 0,
          'spaceHeight must be greater than or equal to 0',
        );

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = [];

    for (int i = 0; i < children.length; i++) {
      columnChildren.add(children[i]);
      if (i < children.length - 1) {
        // Add space after each widget except the last one
        columnChildren.add(SizedBox(height: spaceHeight));
      }
    }

    return ListView(
      padding: padding,
      children: columnChildren,
    );
  }
}
