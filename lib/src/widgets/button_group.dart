import 'package:flutter/material.dart';

class ButtonGroup extends StatelessWidget {
  const ButtonGroup({
    super.key,
    required this.children,
    this.activeIndex,
    this.spacing = 8,
    this.outerRadius,
    this.innerRadius,
    this.shrinkWrap = false,
  });

  final List<Widget> children; // Changed from List<ElevatedButton>
  final int? activeIndex;
  final double spacing;
  final double? outerRadius;
  final double? innerRadius;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final buttongroup = <Widget>[];
    final effectiveOuterRadius = outerRadius ?? _calcOuterRadius(context);
    final effectiveInnerRadius = innerRadius ?? effectiveOuterRadius / 2;

    for (var (i, current) in children.indexed) {
      final borderRadius = BorderRadius.horizontal(
        left: Radius.circular(
          i == 0 || i == activeIndex ? effectiveOuterRadius : effectiveInnerRadius,
        ),
        right: Radius.circular(
          i == children.length - 1 || i == activeIndex
              ? effectiveOuterRadius
              : effectiveInnerRadius,
        ),
      );

      int flex = 0;
      if (current is Expanded) {
        flex = current.flex;
        current = current.child;
      }

      Widget themedChild = Theme(
        data: Theme.of(context).copyWith(
          cardTheme: CardThemeData(shape: RoundedRectangleBorder(borderRadius: borderRadius)),
          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: borderRadius)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
            ),
          ),
        ),
        child: current,
      );

      buttongroup.add(flex > 0 ? Expanded(flex: flex, child: themedChild) : themedChild);
    }

    return Row(
      // Change to Max so the ButtonGroup fills the Expanded space from location_sheet
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: spacing,
      children: buttongroup,
    );
  }

  double _calcOuterRadius(BuildContext context) {
    final themeStyle = Theme.of(context).elevatedButtonTheme.style;
    if (themeStyle?.shape != null) {
      final shape = themeStyle!.shape!.resolve(<WidgetState>{});
      if (shape is RoundedRectangleBorder) {
        final br = shape.borderRadius;
        if (br is BorderRadius) return br.topLeft.x;
      }
    }
    return 12; // Default fallback
  }
}
