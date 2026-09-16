import 'package:flutter/material.dart';

import '../../../screens/detail/widgets/video_feature.dart';
import '../config/spacing/spacing_extension.dart';
import '../config/video_layout_config.dart';

/// Plays a video from [VideoLayoutConfig.url].
///
/// Supports YouTube links (via the embedded YouTube iframe player) and direct video
/// files (mp4, m3u8, …) via `video_player`.
/// For embedding arbitrary web content (Instagram, Vimeo iframe, …),
/// use the `webEmbed` layout instead.
class VideoLayout extends StatelessWidget {
  final VideoLayoutConfig config;

  const VideoLayout({required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    if (config.url.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: config.spacing.margin,
      padding: config.spacing.padding,
      child: FeatureVideoPlayer(config.url, videoConfig: config.videoConfig),
    );
  }
}
