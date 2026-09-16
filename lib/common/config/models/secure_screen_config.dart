/// Configuration for blocking screenshot & screen recording.
///
/// By default this feature is disabled, meaning users can freely capture
/// screenshots or record the screen.
///
/// When [enable] is `true`:
/// - If [screens] is empty, screenshot/recording is blocked for the whole app.
/// - If [screens] is not empty, blocking is only applied while the user is on
///   one of the listed screens (matched against the route name, e.g. values
///   from `RouteList`). Other screens remain unprotected.
class SecureScreenConfig {
  final bool enable;
  final List<String> screens;

  const SecureScreenConfig({this.enable = false, this.screens = const []});

  /// Whether the feature is enabled for the whole app (no specific screens).
  bool get isWholeApp => enable && screens.isEmpty;

  factory SecureScreenConfig.fromJson(Map json) {
    return SecureScreenConfig(
      enable: json['enable'] ?? false,
      screens: List<String>.from(json['screens'] ?? []),
    );
  }

  Map toJson() {
    return {'enable': enable, 'screens': screens};
  }

  SecureScreenConfig copyWith({bool? enable, List<String>? screens}) {
    return SecureScreenConfig(
      enable: enable ?? this.enable,
      screens: screens ?? this.screens,
    );
  }
}
