import 'package:flutter/material.dart';

import '../config/testimonial_config.dart';
import '../index.dart';
import 'testimonial_card.dart';
import 'testimonial_chat.dart';
import 'testimonial_glass.dart';
import 'testimonial_gradient.dart';
import 'testimonial_minimal.dart';
import 'testimonial_modern.dart';
import 'testimonial_quote.dart';

class TestimonialLayout extends StatelessWidget {
  final TestimonialConfig config;
  const TestimonialLayout({required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    switch (config.type) {
      case TestimonialType.chat:
        return TestimonialChat(config: config);
      case TestimonialType.modern:
        return TestimonialModern(config: config);
      case TestimonialType.minimal:
        return TestimonialMinimal(config: config);
      case TestimonialType.gradient:
        return TestimonialGradient(config: config);
      case TestimonialType.quote:
        return TestimonialQuote(config: config);
      case TestimonialType.glass:
        return TestimonialGlass(config: config);
      case TestimonialType.card:
        return TestimonialCard(config: config);
    }
  }
}
