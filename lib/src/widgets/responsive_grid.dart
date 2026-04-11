import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 200,
    this.maxCrossAxisCount = 4,
    this.padding = const EdgeInsets.all(16),
    this.horizontalSpacing = 16,
    this.verticalSpacing = 16,
    this.alignment = WrapAlignment.start,
    this.physics,
  });

  /// List of widgets to display in the grid
  final List<Widget> children;
  final double minItemWidth;
  final int maxCrossAxisCount;

  final EdgeInsets padding;
  final double horizontalSpacing;
  final double verticalSpacing;

  final WrapAlignment alignment;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - padding.horizontal;
        final crossAxisCount = (availableWidth / minItemWidth).floor().clamp(1, maxCrossAxisCount);
        final itemWidth =
            (availableWidth - (crossAxisCount - 1) * horizontalSpacing) / crossAxisCount;

        return SingleChildScrollView(
          physics: physics,
          child: Padding(
            padding: padding,
            child: Wrap(
              spacing: horizontalSpacing,
              runSpacing: verticalSpacing,
              alignment: alignment,
              children: children.map((item) => SizedBox(width: itemWidth, child: item)).toList(),
            ),
          ),
        );
      },
    );
  }
}
