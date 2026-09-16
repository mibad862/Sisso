import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../config/testimonial_config.dart';
import 'testimonial_shared.dart';

/// A polished, elevated testimonial card. Author/body order follows
/// [config.authorInTop] and content alignment follows [config.isLeft]; every
/// shared style field (colors, radius, border, box-shadow, background,
/// margins, quote glyph) is applied through [TestimonialShared.frame].
class TestimonialCard extends StatelessWidget {
  final TestimonialConfig config;
  const TestimonialCard({required this.config, super.key});

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
          body: TestimonialShared.body(
            context: context,
            config: config,
            quoteColor: accent.withValueOpacity(0.6),
            textColor: textColor,
          ),
          author: TestimonialShared.author(
            context: context,
            config: config,
            accent: accent,
            textColor: textColor,
            avatarSize: 56,
            ratingSize: 15,
          ),
        ),
      ),
    );
  }
}
