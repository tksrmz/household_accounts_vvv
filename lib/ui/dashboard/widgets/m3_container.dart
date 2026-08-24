import 'package:flutter/material.dart';

class M3Container extends StatelessWidget {
  final WidgetBuilder builder;
  final ColorScheme colorScheme;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final Color _backgroundColor;
  final Color _foregroundColor;

  M3Container.primary({
    super.key,
    required this.builder,
    required this.colorScheme,
    this.decoration,
    this.padding,
    this.margin,
  }) : _backgroundColor = colorScheme.primary,
       _foregroundColor = colorScheme.onPrimary;

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Override the text theme
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: _foregroundColor,
          displayColor: _foregroundColor,
        ),
      ),
      child: Container(
        padding: padding,
        margin: margin,
        // Set background color
        decoration: decoration?.copyWith(color: _backgroundColor),
        color: decoration == null ? _backgroundColor : null,
        // Need this Builder to get the correct context
        child: Builder(builder: (BuildContext context) => builder(context)),
      ),
    );
  }
}
