import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../config/testimonial_config.dart';
import 'testimonial_shared.dart';

/// A clean, contemporary card: a soft surface, a thin divider between the
/// quote and the author, and the accent-tinted quote glyph.
class TestimonialModern extends StatelessWidget {
  final TestimonialConfig config;
  const TestimonialModern({required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        TestimonialShared.color(config.accentColor) ??
        theme.colorScheme.primary;
    final textColor =
        TestimonialShared.color(config.textColor) ??
        theme.colorScheme.onSurface;

    return TestimonialShared.frame(
      context: context,
      config: config,
      accent: accent,
      elevated: true,
      child: Column(
        crossAxisAlignment: TestimonialShared.columnAlign(config.isLeft),
        mainAxisSize: MainAxisSize.min,
        children: TestimonialShared.ordered(
          config: config,
          spacing: 18,
          body: TestimonialShared.body(
            context: context,
            config: config,
            quoteColor: accent,
            textColor: textColor,
            quoteSize: 36,
          ),
          author: Column(
            crossAxisAlignment: TestimonialShared.columnAlign(config.isLeft),
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(color: textColor.withValueOpacity(0.08), height: 1),
              const SizedBox(height: 16),
              TestimonialShared.author(
                context: context,
                config: config,
                accent: accent,
                textColor: textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
