import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../config/testimonial_config.dart';
import 'testimonial_shared.dart';

/// A glassmorphism card: a translucent, blurred surface with a subtle border.
/// Reads the same radius / border / box-shadow / margin config as the others.
class TestimonialGlass extends StatelessWidget {
  final TestimonialConfig config;
  const TestimonialGlass({required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        TestimonialShared.color(config.accentColor) ??
        theme.colorScheme.primary;
    final tint =
        TestimonialShared.color(config.backgroundColor) ??
        theme.colorScheme.onSurface;
    final textColor =
        TestimonialShared.color(config.textColor) ??
        theme.colorScheme.onSurface;
    final radius = config.borderRadius.toDouble().clamp(16.0, 40.0).toDouble();
    final borderWidth = config.borderWidth > 0
        ? config.borderWidth.toDouble()
        : 1.2;
    final shadowCfg = config.boxShadowConfig;

    return Container(
      margin: TestimonialShared.margin(config),
      decoration: shadowCfg != null
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValueOpacity(shadowCfg.colorOpacity),
                  offset: Offset(shadowCfg.x, shadowCfg.y),
                  blurRadius: shadowCfg.blurRadius,
                  spreadRadius: shadowCfg.spreadRadius,
                ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tint.withValueOpacity(0.15),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: tint.withValueOpacity(0.3),
                width: borderWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: TestimonialShared.columnAlign(config.isLeft),
              mainAxisSize: MainAxisSize.min,
              children: TestimonialShared.ordered(
                config: config,
                spacing: 18,
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
                  accent: accent,
                  textColor: textColor,
                  avatarSize: 44,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
