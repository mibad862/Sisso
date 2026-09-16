import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../config/testimonial_config.dart';
import 'testimonial_shared.dart';

/// A vivid gradient card with light text. The gradient runs from the accent
/// color to a darker shade of it.
class TestimonialGradient extends StatelessWidget {
  final TestimonialConfig config;
  const TestimonialGradient({required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start =
        TestimonialShared.color(config.accentColor) ??
        theme.colorScheme.primary;
    final end = Color.lerp(start, Colors.black, 0.35)!;
    final textColor = TestimonialShared.color(config.textColor) ?? Colors.white;

    return TestimonialShared.frame(
      context: context,
      config: config,
      accent: textColor,
      padding: const EdgeInsets.all(22),
      gradient: LinearGradient(
        colors: [start, end],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: TestimonialShared.columnAlign(config.isLeft),
        mainAxisSize: MainAxisSize.min,
        children: TestimonialShared.ordered(
          config: config,
          spacing: 20,
          body: TestimonialShared.body(
            context: context,
            config: config,
            quoteColor: textColor.withValueOpacity(0.85),
            textColor: textColor,
            quoteSize: 34,
          ),
          author: TestimonialShared.author(
            context: context,
            config: config,
            accent: textColor,
            textColor: textColor,
            avatarSize: 46,
          ),
        ),
      ),
    );
  }
}
