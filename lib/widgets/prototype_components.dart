import 'package:flutter/material.dart';

import '../theme/prototype_theme.dart';

class PrototypePanel extends StatelessWidget {
  const PrototypePanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.backgroundColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final tokens = prototypeTokens(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tokens.border),
      ),
      child: child,
    );
  }
}

class PrototypeSectionHeader extends StatelessWidget {
  const PrototypeSectionHeader({
    required this.eyebrow,
    required this.title,
    required this.body,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tokens = prototypeTokens(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: TextStyle(color: tokens.success, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.22,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: const TextStyle(
            fontSize: 16,
            height: 1.55,
            color: Color(0xFF4D5C57),
          ),
        ),
      ],
    );
  }
}

class PrototypeResponsiveGrid extends StatelessWidget {
  const PrototypeResponsiveGrid({
    required this.children,
    required this.minItemWidth,
    super.key,
  });

  final List<Widget> children;
  final double minItemWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minItemWidth).floor().clamp(
          1,
          3,
        );
        final itemWidth = (constraints.maxWidth - (columns - 1) * 14) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class StatusRow extends StatelessWidget {
  const StatusRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(height: 1.4))),
      ],
    );
  }
}
