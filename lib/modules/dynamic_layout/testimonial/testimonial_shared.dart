import 'package:flutter/material.dart';
import 'package:flux_ui/flux_ui.dart';

import '../../../common/tools.dart';
import '../../../widgets/common/star_rating.dart';
import '../config/testimonial_config.dart';

/// Shared building blocks reused by every testimonial design so that all
/// designs honour the exact same config fields (colors, radius, border,
/// box-shadow, margins, background, alignment, author position and the
/// decorative quote glyph).
class TestimonialShared {
  const TestimonialShared._();

  /// Resolves a hex color, returning `null` when the config value is empty so
  /// callers can fall back to a theme color instead of an opaque white.
  static Color? color(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    return HexColor(hex);
  }

  /// Outer margin driven by the config, applied by every design.
  static EdgeInsets margin(TestimonialConfig config) => EdgeInsets.only(
    left: config.marginLeft.toDouble(),
    right: config.marginRight.toDouble(),
    top: config.marginTop.toDouble(),
    bottom: config.marginBottom.toDouble(),
  );

  static CrossAxisAlignment columnAlign(bool isLeft) =>
      isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end;

  static TextAlign textAlign(bool isLeft) =>
      isLeft ? TextAlign.start : TextAlign.end;

  /// Universal container: applies margin, radius, optional border, optional
  /// surface/gradient fill (driven by [config.enableBackground] or [elevated])
  /// and the configured box-shadow. Used by all designs except the glass one
  /// (which needs a backdrop blur but still reads the same fields directly).
  static Widget frame({
    required BuildContext context,
    required TestimonialConfig config,
    required Color accent,
    required Widget child,
    bool elevated = false,
    Gradient? gradient,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    final theme = Theme.of(context);
    final radius = config.borderRadius.toDouble().clamp(0.0, 40.0).toDouble();
    final surfaceColor =
        color(config.backgroundColor) ?? theme.colorScheme.surface;
    final wantSurface =
        gradient != null || elevated || (config.enableBackground ?? false);
    final shadowCfg = config.boxShadowConfig;
    final shadows = <BoxShadow>[
      if (shadowCfg != null)
        BoxShadow(
          color: Colors.grey.withValueOpacity(shadowCfg.colorOpacity),
          offset: Offset(shadowCfg.x, shadowCfg.y),
          blurRadius: shadowCfg.blurRadius,
          spreadRadius: shadowCfg.spreadRadius,
        )
      else if (elevated)
        BoxShadow(
          color: Colors.black.withValueOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
    ];

    return Container(
      margin: margin(config),
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null && wantSurface ? surfaceColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: config.borderWidth > 0
            ? Border.all(
                color: accent.withValueOpacity(0.3),
                width: config.borderWidth.toDouble(),
              )
            : null,
        boxShadow: shadows.isEmpty ? null : shadows,
      ),
      child: child,
    );
  }

  /// Circular avatar with a graceful fallback icon.
  static Widget avatar(
    TestimonialConfig config, {
    double size = 56,
    Color? fallbackBackground,
    Color? fallbackIconColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: SizedBox(
        width: size,
        height: size,
        child: config.avatar != null
            ? FluxImage(
                imageUrl: config.avatar!,
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            : Container(
                color: fallbackBackground ?? Colors.grey.withValueOpacity(0.2),
                child: Icon(
                  Icons.person,
                  size: size * 0.5,
                  color: fallbackIconColor,
                ),
              ),
      ),
    );
  }

  /// Star rating row, hidden when no rating is provided.
  static Widget? rating(
    TestimonialConfig config, {
    double size = 14,
    Color? color,
  }) {
    if (config.rating == null) return null;
    return SmoothStarRating(
      size: size,
      color: color,
      borderColor: color?.withValueOpacity(0.4),
      rating: config.rating?.toDouble(),
    );
  }

  /// Decorative quote glyph rendered with the design accent color.
  static Widget quoteIcon({
    required Color color,
    double size = 40,
    bool flip = false,
  }) {
    final icon = Icon(Icons.format_quote_rounded, size: size, color: color);
    if (!flip) return icon;
    return Transform.rotate(angle: 3.14159, child: icon);
  }

  /// Quote body (optional glyph + testimonial text), aligned via
  /// [config.isLeft] and honouring [config.showQuoteIcon].
  static Widget body({
    required BuildContext context,
    required TestimonialConfig config,
    required Color quoteColor,
    required Color textColor,
    double quoteSize = 34,
    TextStyle? textStyle,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: columnAlign(config.isLeft),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (config.showQuoteIcon) ...[
          quoteIcon(color: quoteColor, size: quoteSize),
          const SizedBox(height: 4),
        ],
        Text(
          config.testimonial,
          textAlign: textAlign(config.isLeft),
          style:
              textStyle ??
              theme.textTheme.bodyLarge?.copyWith(
                color: textColor,
                height: 1.5,
              ),
        ),
      ],
    );
  }

  /// Author block (avatar + name + major + rating). The avatar sits on the
  /// leading edge for [config.isLeft] == true and on the trailing edge
  /// otherwise, keeping the design in sync with the body alignment.
  static Widget author({
    required BuildContext context,
    required TestimonialConfig config,
    required Color accent,
    required Color textColor,
    double avatarSize = 48,
    double ratingSize = 14,
  }) {
    final theme = Theme.of(context);
    final isLeft = config.isLeft;

    final info = Column(
      crossAxisAlignment: columnAlign(isLeft),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (config.name != null)
          Text(
            config.name!,
            textAlign: textAlign(isLeft),
            style: theme.textTheme.titleSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (config.major != null)
          Text(
            config.major!,
            textAlign: textAlign(isLeft),
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor.withValueOpacity(0.65),
              fontStyle: FontStyle.italic,
            ),
          ),
        if (config.rating != null) ...[
          const SizedBox(height: 6),
          rating(config, size: ratingSize, color: accent)!,
        ],
      ],
    );

    final avatarWidget = avatar(
      config,
      size: avatarSize,
      fallbackBackground: accent.withValueOpacity(0.15),
      fallbackIconColor: accent,
    );

    final children = isLeft
        ? [avatarWidget, const SizedBox(width: 12), Flexible(child: info)]
        : [Flexible(child: info), const SizedBox(width: 12), avatarWidget];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isLeft
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: children,
    );
  }

  /// Orders the [author] and [body] blocks according to [config.authorInTop].
  static List<Widget> ordered({
    required TestimonialConfig config,
    required Widget author,
    required Widget body,
    double spacing = 16,
  }) {
    return config.authorInTop
        ? [author, SizedBox(height: spacing), body]
        : [body, SizedBox(height: spacing), author];
  }
}
