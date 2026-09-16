import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../config/testimonial_config.dart';
import 'testimonial_shared.dart';

/// A minimalist design: a slim accent bar on the leading edge with a compact,
/// lightweight author + quote stack.
class TestimonialMinimal extends StatelessWidget {
  final TestimonialConfig config;
  const TestimonialMinimal({required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        TestimonialShared.color(config.accentColor) ??
        theme.colorScheme.primary;
    final textColor =
        TestimonialShared.color(config.textColor) ??
        theme.colorScheme.onSurface;
    final isLeft = config.isLeft;

    final bar = Container(width: 3, color: accent);
    final content = Expanded(
      child: Column(
        crossAxisAlignment: TestimonialShared.columnAlign(isLeft),
        mainAxisSize: MainAxisSize.min,
        children: TestimonialShared.ordered(
          config: config,
          spacing: 10,
          author: TestimonialShared.author(
            context: context,
            config: config,
            accent: accent,
            textColor: textColor,
            avatarSize: 40,
            ratingSize: 13,
          ),
          body: TestimonialShared.body(
            context: context,
            config: config,
            quoteColor: accent.withValueOpacity(0.6),
            textColor: textColor.withValueOpacity(0.85),
            quoteSize: 26,
            textStyle: theme.textTheme.bodyMedium?.copyWith(
              color: textColor.withValueOpacity(0.85),
              height: 1.5,
            ),
          ),
        ),
      ),
    );

    return TestimonialShared.frame(
      context: context,
      config: config,
      accent: accent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: isLeft
              ? [bar, const SizedBox(width: 12), content]
              : [content, const SizedBox(width: 12), bar],
        ),
      ),
    );
  }
}
