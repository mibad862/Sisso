import '../../../common/config/models/video_config.dart';
import 'spacing/spacing_config.dart';

/// Config for the `video` dynamic layout.
///
/// ```json
/// {
///   "layout": "video",
///   "url": "https://www.youtube.com/watch?v=aqz-KE-bpKQ",
///   "autoPlay": false,
///   "isSoundOn": true,
///   "margin": {"top": 10.0, "bottom": 10.0}
/// }
/// ```
class VideoLayoutConfig {
  /// Video source: a YouTube link, a direct video file (mp4, m3u8, …)
  /// or an asset path.
  final String url;

  /// Player behavior (autoPlay, aspectRatio, isSoundOn, enableLoop, …),
  /// parsed from the same flat json.
  final VideoConfig videoConfig;

  /// Outer margin / inner padding of the layout.
  final SpacingConfig spacing;

  const VideoLayoutConfig({
    this.url = '',
    this.videoConfig = const VideoConfig(),
    this.spacing = const SpacingConfig(),
  });

  factory VideoLayoutConfig.fromJson(Map<String, dynamic> json) {
    return VideoLayoutConfig(
      url: json['url'] ?? '',
      videoConfig: VideoConfig.fromJson(json),
      spacing: SpacingConfig.fromJson(json),
    );
  }
}
