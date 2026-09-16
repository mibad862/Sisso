import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../config/testimonial_config.dart';
import 'testimonial_shared.dart';

/// An elegant quote design with a large glyph and italic text.
class TestimonialQuote extends StatelessWidget {
  final TestimonialConfig config;
  const TestimonialQuote({required this.config, super.key});

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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: TestimonialShared.columnAlign(config.isLeft),
        mainAxisSize: MainAxisSize.min,
        children: TestimonialShared.ordered(
          config: config,
          spacing: 20,
          body: TestimonialShared.body(
            context: context,
            config: config,
            quoteColor: accent.withValueOpacity(0.5),
            textColor: textColor,
            quoteSize: 52,
            textStyle: theme.textTheme.titleMedium?.copyWith(
              color: textColor,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          author: TestimonialShared.author(
            context: context,
            config: config,
            accent: accent,
            textColor: textColor,
            avatarSize: 52,
            ratingSize: 16,
          ),
        ),
      ),
    );
  }
}
