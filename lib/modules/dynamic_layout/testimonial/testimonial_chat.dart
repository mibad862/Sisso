import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../config/testimonial_config.dart';
import 'testimonial_shared.dart';

/// A modern chat-bubble testimonial. The bubble is drawn with
/// [_ChatBubblePainter] (a [CustomPainter]) so it gets a real speech tail
/// pointing toward the avatar. [config.isLeft] flips the bubble/author side,
/// [config.authorInTop] places the author above/below, and every shared style
/// field is honoured.
class TestimonialChat extends StatelessWidget {
  final TestimonialConfig config;
  const TestimonialChat({required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLeft = config.isLeft;
    final accent =
        TestimonialShared.color(config.accentColor) ??
        theme.colorScheme.primary;
    final bubbleColor =
        TestimonialShared.color(config.backgroundColor) ??
        accent.withValueOpacity(0.12);
    final textColor =
        TestimonialShared.color(config.textColor) ??
        theme.colorScheme.onSurface;
    final radius = config.borderRadius.toDouble().clamp(8.0, 28.0).toDouble();
    final shadowCfg = config.boxShadowConfig;

    final bubble = CustomPaint(
      painter: _ChatBubblePainter(
        color: bubbleColor,
        isLeft: isLeft,
        radius: radius,
        shadowColor: shadowCfg != null
            ? Colors.grey.withValueOpacity(shadowCfg.colorOpacity)
            : Colors.black.withValueOpacity(0.08),
        shadowBlur: shadowCfg?.blurRadius ?? 8,
        borderColor: config.borderWidth > 0
            ? accent.withValueOpacity(0.4)
            : null,
        borderWidth: config.borderWidth.toDouble(),
      ),
      child: Padding(
        // Extra padding on the tail side so text never overlaps the pointer.
        padding: EdgeInsets.fromLTRB(
          isLeft ? 18 : 16,
          14,
          isLeft ? 16 : 18,
          16,
        ),
        child: TestimonialShared.body(
          context: context,
          config: config,
          quoteColor: accent.withValueOpacity(0.6),
          textColor: textColor,
          quoteSize: 24,
          textStyle: theme.textTheme.bodyLarge?.copyWith(
            color: textColor,
            height: 1.45,
          ),
        ),
      ),
    );

    return Container(
      margin: TestimonialShared.margin(config),
      padding: config.enableBackground == true
          ? const EdgeInsets.all(12)
          : EdgeInsets.zero,
      decoration: config.enableBackground == true
          ? BoxDecoration(
              color:
                  TestimonialShared.color(config.backgroundColor) ??
                  theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(radius),
            )
          : null,
      child: Column(
        crossAxisAlignment: TestimonialShared.columnAlign(isLeft),
        mainAxisSize: MainAxisSize.min,
        children: TestimonialShared.ordered(
          config: config,
          spacing: 14,
          body: Padding(
            // Leave room for the speech tail on the avatar side.
            padding: EdgeInsets.only(
              left: isLeft ? 10 : 0,
              right: isLeft ? 0 : 10,
            ),
            child: bubble,
          ),
          author: TestimonialShared.author(
            context: context,
            config: config,
            accent: accent,
            textColor: textColor,
            avatarSize: 52,
          ),
        ),
      ),
    );
  }
}

/// Paints a rounded speech bubble with a small triangular tail on the bottom
/// edge, pointing toward the avatar ([isLeft] decides which side).
class _ChatBubblePainter extends CustomPainter {
  final Color color;
  final bool isLeft;
  final double radius;
  final Color shadowColor;
  final double shadowBlur;
  final Color? borderColor;
  final double borderWidth;

  _ChatBubblePainter({
    required this.color,
    required this.isLeft,
    required this.radius,
    required this.shadowColor,
    required this.shadowBlur,
    this.borderColor,
    this.borderWidth = 0,
  });

  Path _buildPath(Size size) {
    const tailWidth = 18.0;
    const tailHeight = 12.0;
    final r = radius.clamp(0.0, size.shortestSide / 2);
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(r),
    );
    final path = Path()..addRRect(body);

    // Tail anchored near the bottom, offset toward the avatar side.
    final tail = Path();
    if (isLeft) {
      final baseX = r + 8;
      tail
        ..moveTo(baseX, size.height - 0.5)
        ..lineTo(baseX - tailWidth / 2, size.height + tailHeight)
        ..lineTo(baseX + tailWidth / 2, size.height - 0.5)
        ..close();
    } else {
      final baseX = size.width - r - 8;
      tail
        ..moveTo(baseX, size.height - 0.5)
        ..lineTo(baseX + tailWidth / 2, size.height + tailHeight)
        ..lineTo(baseX - tailWidth / 2, size.height - 0.5)
        ..close();
    }
    return Path.combine(PathOperation.union, path, tail);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);

    canvas.drawShadow(path, shadowColor, shadowBlur, true);
    canvas.drawPath(path, Paint()..color = color);

    if (borderColor != null && borderWidth > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = borderColor!
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChatBubblePainter old) {
    return old.color != color ||
        old.isLeft != isLeft ||
        old.radius != radius ||
        old.shadowColor != shadowColor ||
        old.shadowBlur != shadowBlur ||
        old.borderColor != borderColor ||
        old.borderWidth != borderWidth;
  }
}
